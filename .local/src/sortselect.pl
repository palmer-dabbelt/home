#!/usr/bin/env perl

# Originally from b1b3f49 ("ARM: config: sort select statements
# alphanumerically") by Russel King.

while (<>) {
        while (/\\\s*$/) {
                $_ .= <>;
        }
        undef %selects if /^\s*config\s+/;
        if (/^\s+select\s+(\w+).*/) {
                if (defined($selects{$1})) {
                        if ($selects{$1} eq $_) {
                                print STDERR "Warning: removing duplicated $1 entry\n";
                        } else {
                                print STDERR "Error: $1 differently selected\n".
                                        "\tOld: $selects{$1}\n".
                                        "\tNew: $_\n";
                                exit 1;
                        }
                }
                $selects{$1} = $_;
                next;
        }
        if (%selects and (/^\s*$/ or /^\s+help/ or /^\s+---help---/ or
                          /^endif/ or /^endchoice/)) {
                foreach $k (sort (keys %selects)) {
                        print "$selects{$k}";
                }
                undef %selects;
        }
        print;
}
if (%selects) {
        foreach $k (sort (keys %selects)) {
                print "$selects{$k}";
        }
}
