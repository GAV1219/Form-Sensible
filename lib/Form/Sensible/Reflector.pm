package Form::Sensible::Form::Reflector;
use Moose;
use namespace::autoclean;
use Carp;
use Data::Dumper;
#extends 'Form::Sensible', 'Form::Sensible::Form';
our $VERSION = '0.01';

# ABSTRACT: A simple reflector class for Form::Sensible

sub reflect_from {
    my ( $self, $handle, $options) = @_;

   	my $form;
    if (exists($options->{'form'})) {
        if ( ref($options->{'form'}) eq 'HASH' ) {
    		$form = Form::Sensible::Form->new($form);
        } elsif ( ref($options->{'form'}) && 
                  UNIVERSAL::can($options->{'form'}, 'isa') &&
                  $options->{'form'}->isa('Form::Sensible::Form') ) {
            $form = $options->{'form'};
        } else {
            croak "form element provided in options, but it's not a form or a hash.  What am I supposed to do with it?";
        }
    } else {
        if (exists($options->{'form_name'})) {
            $form = Form::Sensible::Form->new( name => $options->{'form_name'});
        } else {
            croak "No form provided, and no form name provided.  Give me something to work with?"
        }
    }
    
    my @fields = $self->get_fieldnames($form, $handle);
    #my @definitions;
    if (exists($options->{'fieldname_filter'}) && ref($options->{'fieldname_filter'}) eq 'CODE') {
        @fields = $options->{'fieldname_filter'}->(@fields);
    }
    
    # this little chunk of code walks a fieldmap, if provided, and ensures that there
    # is a map entry for every field we know about.  If none was provided, it creates
    # one for the field set to undef - which means do not add the field to the form.

    my $fieldmap = map { $_ => $_ } @fields;
    if (exists($options->{'fieldname_map'}) && ref($options->{'fieldname_map'}) eq 'HASH') {
        foreach my $field (@fields) {
            if (exists($options->{'fieldname_map'}{$field})) {
                $fieldmap->{$field} = $options->{'fieldname_map'}{$field};
            } else {
                $fieldmap->{$field} = undef;
            }
        }
    }

    foreach my $fieldname (@fields) {
	   my $field_def = $self->get_field_definition($form, $handle, $fieldname);
	   my $new_fieldname = $fieldmap->{$fieldname};
	   warn "Processing: " . $fieldname . " as " . $new_fieldname;
	   
	   if ( defined($new_fieldname) ) {
           $form->add_field($field_def, $new_fieldname);
       }
    }
    
    warn "Form in create_form: " . Dumper $form;
    return $form;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Form::Sensible::Form::Reflector - A base class for writing Form::Sensible reflectors.

=cut

=head1 SYNOPSIS

    my $reflector = Form::Sensible::Form::Reflector::SomeSubclass->new();

    my $generated_form = $reflector->reflect_from($data_source, $options);

=head1 DESCRIPTION

A Reflector in Form::Sensible is a class that inspects a data source and
creates a form based on what it finds there. In other words it creates a form
that 'reflects' the data elements found in the data source.

A good example of this would be to create forms based on a DBIx::Class
result_source (or table definition.) Using the DBIC reflector, you could
create form for editing a user's profile information simply by passing the
User result_source into the reflector.

This module is a base class for writing reflectors, meaning you do not use
this class directly. Instead you use one of the subclasses that deal with your
data source type.

=head1 CREATING YOUR OWN REFLECTOR

Creating a new reflector class is extraordinarily simple. All you need to do
is create a subclass of Form::Sensible::Reflector and then create two
subroutines: C<get_fieldnames> and C<get_field_definition>.

As you might expect, C<get_fieldnames> should return an array containing the
names of the fields that are to be created. C<get_field_definition> is then
called for each field to be created and should return a hashref representing
that field suitable for passing to the
L<Form::Sensible::Field|Form::Sensible::Field> C<create_from_flattened>
method.

Note that in both cases, the contents of C<$datasource> are specific to your
reflector subclass and are not inspected in any way by the base class.

=head2 Subclass Boilerplate

    package My::Reflector;
    use Moose;
    use namespace::autoclean;
    extends 'Form::Sensible::Form::Reflector';

    sub get_fieldnames {
        my ($self, $form, $datasource) = @_;
        my @fieldnames;
        
        foreach my $field ($datasource->the_way_to_get_all_your_fields()) {
            push @fieldnames, $field->name;
        }
        return @fieldnames;
    }

    sub get_field_definition { 
        my ($self, $form, $datasource, $fieldname) = @_;
        
        my $field_definition = {
            name => $fieldname
        };
        
        ## inspect $datasource's $fieldname and add things to $field_definition
        
        return $field_definition;
    }


=head2 Author's note 

This is a base class to write reflectors for things like, configuration files,
or my favorite, a database schema.

The idea is to give you something that creates a form from some other source
that already defines form-like properties, ie a database schema that already
has all the properties and fields a form would need.

I personally hate dealing with forms that are longer than a search field or
login form, so this really fits into my style.

=head1 AUTHOR

Devin Austin <dhoss@cpan.org>

=cut

=head1 ACKNOWLEDGEMENTS

Jay Kuri <jayk@cpan.org> for his awesome Form::Sensible library and helping me
get this library in tune with it.

=cut

=head1 SEE ALSO

L<Form::Sensible>
L<Form::Sensible> Wiki: L<http://wiki.catalyzed.org/cpan-modules/form-sensible>
L<Form::Sensible> Discussion: L<http://groups.google.com/group/formsensible>

=cut