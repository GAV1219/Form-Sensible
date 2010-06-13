package Form::Sensible::Field::Toggle;

use Moose; 
use namespace::autoclean;
extends 'Form::Sensible::Field::Select';

## provides a simple on/off field

has 'on_value' => (
    is          => 'rw',
    default     => 'on',
);

has 'off_value' => (
    is          => 'rw',
    default     => 'off',
);

has 'on_label' => (
    is          => 'rw',
    isa         => 'Str',
    lazy        => 1,
    default     => sub { ucfirst(shift->on_value)},
);

has 'off_label' => (
    is          => 'rw',
    isa         => 'Str',
    lazy        => 1,
    default     => sub { ucfirst(shift->off_value)},
);


sub get_additional_configuration {
    my $self = shift;
    
    return { 
                'on_value' => $self->on_value,
                'off_value' => $self->off_value
           };

}

sub options {
    my $self = shift;
    
    return [ { 
                 name => $self->on_label, 
                 value => $self->on_value
             },
             { 
                 name => $self->off_label, 
                 value => $self->off_value
             },
           ];
}

sub accepts_multiple {
    my $self = shift;
    return 0;
}

#sub validate {
#    my $self = shift;
#    
#    if ($self->value ne $self->on_value && $self->value ne $self->off_value) {
#    
#        if (exists($self->validation->{'invalid_message'})) {
#            return $self->validation->{'invalid_message'};
#        } else {
#            return $self->display_name . " was set to an invalid value";            
#        }        
#    } else {
#        return 0;
#    }
#}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Form::Sensible::Field::Toggle - An on/off field

=head1 SYNOPSIS

    use Form::Sensible::Field::Toggle;
    
    my $object = Form::Sensible::Field::Toggle->new( 
                                                      on_value => '100',
                                                      off_value => '0'
                                                    );

=head1 DESCRIPTION

The Toggle field type represents a simple on/off selector.  A value is 
provided for both on and off states.  A toggle can often be rendered in
the same ways as a C<Select|Form::Sensible::Field::Select> field type, as
in most cases it can be treated as a select with only two options, on and off.

=head1 ATTRIBUTES

=over 8

=item C<'on_value'> 

The value to be used when the field is in the 'ON' state.

=item C<'off_value'> has

The value to be used when the field is in the 'OFF' state.

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