package Form::Sensible::Renderer::HTML;

use Moose; 
use namespace::autoclean;
use Template;
use Data::Dumper;
use Form::Sensible::Renderer::HTML::RenderedForm;
extends 'Form::Sensible::Renderer';

has 'include_paths' => (
    is          => 'rw',
    isa         => 'ArrayRef[Str]',
    required    => 1,
    lazy        => 1,
    default     => sub { my $self = shift; return [ File::ShareDir::dist_dir('Form-Sensible') . '/templates/' . $self->base_theme . '/' ]; },
);

has 'base_theme' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
    default     => 'default'
);


has 'tt_config' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub {
                              my $self = shift;
                              return {
                                      INCLUDE_PATH => $self->include_paths()
                              }; 
                         },
    lazy        => 1,
);

## if template is provided, it will be re-used.  
## otherwise, a new one is generated for each form render.
has 'template' => (
    is          => 'rw',
    isa         => 'Template',
);

has 'default_options' => (
    is          => 'rw',
    isa         => 'HashRef',
    required    => 1,
    default     => sub { return {}; },
    lazy        => 1,
);


sub render {
    my ($self, $form, $stash_prefill, $options) = @_;
    
    my $template_options = $self->default_options;
    
    # steps
    # use or create Template object with options
    # merge stash prefill
    # create RenderedForm object
    # setup RenderedForm object
    # return renderedForm object

    if (!defined($stash_prefill)) {
        $stash_prefill = {};
    }
    my $form_specific_stash = { %{$stash_prefill} };
    
    my $template = $self->template;
    
    ## if there is no $self->template - we have to 
    ## create one, but we don't keep it if we create it,
    ## we just use it for this render.
    if (!defined($template)) {
        $template = $self->new_template();
    }
    
    my %args = (
                    template => $template,
                    form => $form,
                    stash => $form_specific_stash,
                );

    # load up default options.
    foreach my $key (keys %{$template_options}) {
        $args{$key} = $template_options->{$key};
    }
    
    if (ref($options) eq 'HASH') {
        foreach my $key (keys %{$options}) {
            $args{$key} = $options->{$key};
        }
    }
    
    ## take care of any subforms we have in this form.
    my $subform_init_hash = { %args };
    $args{'subform_renderers'} = {};
    foreach my $field ($form->get_fields()) {
        my $fieldname = $field->name();
        if ($field->isa('Form::Sensible::Field::SubForm')) {
            $subform_init_hash->{'form'} = $field->form;
            #print "FOO!! $fieldname\n";
            $args{'subform_renderers'}{$fieldname} = Form::Sensible::Renderer::HTML::RenderedForm->new( $subform_init_hash );
            #print Dumper($args{'subform_renderers'}{$fieldname});
            
            ## dirty hack for now.  If we have subforms, then we automatically assume we have to be
            ## multipart/form-data.  What we should do is check all the subforms... but we aren't doing that at this point.
            $args{'stash'}{'form_enctype'} = 'multipart/form-data'
        } elsif ($field->isa('Form::Sensible::Field::FileSelector')) {
            $args{'stash'}{'form_enctype'} = 'multipart/form-data';
        }
    }
    
    my $rendered_form = Form::Sensible::Renderer::HTML::RenderedForm->new( %args );
    
    return $rendered_form;
}

# create a new Template instance with the provided options. 
sub new_template {
    my ($self) = @_;
    
    return Template->new( $self->tt_config );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Renderer::HTML - an HTML based Form renderer

=head1 SYNOPSIS

    use Form::Sensible::Renderer::HTML;
    
    my $object = Form::Sensible::Renderer::HTML->new();

    $object->do_stuff();

=head1 DESCRIPTION

Renders a form as an HTML form.  Returns a 
L<Form::Sensible::Renderer::HTML::RenderedForm|Form::Sensible::Renderer::HTML::RenderedForm> object.

=head1 ATTRIBUTES

=over 8

=item C<template>

The L<Template> object used by this renderer.  You can provide your own by setting this attribute.
If you do not set it, a new Template object is created using the parameter below.

=item C<include_paths>

An arrayref containing the filesystem paths to search for field templates.

=item C<base_theme>

The theme to use for form rendering.  Defaults to C<default>, currently 
the only theme distributed with Form::Sensible.

=item C<tt_config>

The config used when creating a new Template object.

=item C<default_options>

Default options to pass through to the L<RenderedForm|Form::Sensible::Renderer::HTML::RenderedForm>.

=back

=head1 METHODS

=over 8

=item C<render($form)> 

Returns a L<RenderedForm|Form::Sensible::Renderer::HTML::RenderedForm> for the form provided.

=item C<new_template()>

Returns a new L<Template|Template> object created using the C<tt_config> attribute.

=back

=head1 AUTHOR

Jay Kuri - E<lt>jayk@cpan.orgE<gt>

=head1 SPONSORED BY

Ionzero LLC. L<http://ionzero.com/>

=head1 SEE ALSO

L<Form::Sensible>

=head1 LICENSE

Copyright 2009 by Jay Kuri E<lt>jayk@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut