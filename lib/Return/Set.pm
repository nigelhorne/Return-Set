package Return::Set;

use strict;
use warnings;

use Exporter 'import';
use Carp qw(croak);
use Params::Get;
use Params::Validate::Strict qw(validate_strict);

our @EXPORT_OK = qw(set);
our $VERSION   = '0.06';

=head1 NAME

Return::Set - Return a value optionally validated against a strict schema

=head1 SYNOPSIS

    use Return::Set qw(set);

    my $value = set($value);  # Just returns $value

    my $value = set($value, { type => SCALAR });  # Validates $value is a scalar

=head1 DESCRIPTION

Exports a single function, C<set>, which returns a given value. If a
validation schema is provided, the value is validated using
L<Params::Validate::Strict>. If validation fails, it croaks.

=head1 FUNCTIONS

=head2 set($value, $schema)

Returns C<$value>. If C<$schema> is provided, validates the value against it.
Croaks if validation fails.

=cut

sub set {
	my $value;
	my $schema;

	if(scalar(@_) == 0) {
		croak(__PACKAGE__, ': Usage: set(value, [ schema ])');
	} elsif(scalar(@_) == 2) {
		$value = $_[0];
		$schema = $_[1];
	} else {
		my $params = Params::Get::get_params('value', \@_);
		$value = $params->{'value'};
		$schema = $params->{'schema'};
	}

    if (defined $schema) {
        eval {
            validate_strict(args => { 'value' => $value }, schema => { 'value' => $schema });
            1;
        } or croak "Validation failed: $@";
    }

    return $value;
}

1;

=head1 AUTHOR

Your Name <you@example.com>

=head1 LICENSE

This module is released under the same terms as Perl itself.

=cut
