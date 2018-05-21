#! /usr/bin/perl -w
#
# monitor_pl
#

use Data::Dumper;

$hostname   = shift or die "Ingrese hostname";
$community  = shift or die "Ingrese comunidad SNMP";
$pseudowire = shift or die "Ingrese Pseudowire";

my $debug = 0;
my %estado;

$oid = ".1.3.6.1.4.1.9.10.106.1.2.1";

$comando = "snmpwalk -v 2c -On -c $community $hostname  $oid";
print $comando."\n" if $debug;

my @reply = qx{$comando};

my $is_real = 0;

foreach $line (@reply)
{
    print $line if $debug;

    if ($line=~/$oid.(\d*).$pseudowire\s*=\s*\S*:\s*(.*)$/)
    {
        $estado{$1} = $2;
        $is_real++;
    }
}

print Dumper \%estado if $debug;

if ($is_real == 0)
{
    $RESULTADO = sprintf("Warning, Link doesnt exists\n");
    print $RESULTADO;
    exit (1);
}

$cpwVcAdminStatus = $estado{25};
$cpwVcOperStatus  = $estado{26};
$cpwVcname        = $estado{22};
$cpwVcUptime      = $estado{24};



if (($cpwVcAdminStatus eq '1') and ($cpwVcOperStatus eq '1'))
{
    $RESULTADO = sprintf("OK - Link %s up for %s\n", $cpwVcname, $cpwVcUptime);
    print $RESULTADO;
    exit (0);
}
elsif (($cpwVcAdminStatus eq '1') and ($cpwVcOperStatus eq '2'))
{
    $RESULTADO = sprintf("Critical - Link %s Admin Up; Operational Down\n", $cpwVcname);
    print $RESULTADO;
    exit (2);
}
else
{
    $RESULTADO = sprintf("Critical - Admin Up; Operational Down\n", $cpwVcname);
    print $RESULTADO;
    exit (2);
}



printf ("UNKNOWN\n");
exit(3);
