package Return::Set;

use strict;
use warnings;
use 5.010;

use parent 'Exporter';

use Carp qw(croak);
use Params::Get 0.13;
use Params::Validate::Strict 0.37 qw(validate_strict);

our @EXPORT_OK = qw(set_return);

=head1 NAME

Return::Set - Return a value optionally validated against a strict schema

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

    use Return::Set qw(set_return);

    return set_return($value);	# Just returns $value

    return set_return($value, { type => 'integer' });	# Validates $value is an integer

=head1 DESCRIPTION

If a validation schema is provided, the value is validated using
L<Params::Validate::Strict>.
If validation fails, it croaks.

When used hand-in-hand with L<Params::Get>,
you should be able to formally specify the input and output sets for a method.

Exports a single function, C<set_return>, which returns a given value.

=head1 FUNCTIONS

=head2 set_return

Returns the given value, optionally validating it against a schema.

Three calling forms are accepted:

=over 4

=item set_return($value)

Returns C<$value> immediately with no validation.

=item set_return($value, $schema)

Returns C<$value> after validating it against C<$schema>
(a L<Params::Validate::Strict> schema hashref, e.g. C<< { type => 'integer' } >>).
Croaks if validation fails.

=item set_return(\%args)

Named-parameter form.
C<%args> may contain C<output> (preferred) or C<value> (accepted for backwards
compatibility) for the return value, and C<schema> for the optional schema.
Croaks if validation fails.

=back

=cut

sub set_return {
	my $value;
	my $schema;

	if((scalar(@_) == 1) && !ref($_[0])) {
		return $_[0];	 # Simple scalar case with no schema, so no validation is possible
	}

	if(scalar(@_) == 2) {
		($value, $schema) = @_;
	} else {
		my $params = Params::Get::get_params('output', \@_);
		$value = $params->{'output'} // $params->{'value'};
		$schema = $params->{'schema'};
	}

	if(defined($schema)) {
		eval {
			validate_strict(args => { 'output' => $value }, schema => { 'output' => $schema });
			1;
		} or do {
			my $err = $@;
			if(!defined($value)) {
				croak "Validation failed, value is undefined: $err";
			}
			if(!ref($value)) {
				croak "Validation failed, $value is invalid: $err";
			}
			croak "Validation failed: $err";
		}
	}

	return $value;
}

=head1 AUTHOR

Nigel Horne, C<< <njh at nigelhorne.com> >>

=head1 SEE ALSO

=over 4

=item * L<Params::Validate::Strict>

=item * L<Params::Get>

=back

=head1 SUPPORT

This module is provided as-is without any warranty.

=head1 LICENCE AND COPYRIGHT

Copyright 2025-2026 Nigel Horne.

Usage is subject to the GPL2 licence terms.
If you use it,
please let me know.

=cut

1;
