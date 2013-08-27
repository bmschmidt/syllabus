#!/usr/bin/perl
# getBibTeXFromZotero - get a bibtex file with all references from Zotero
#                       using MozRepl
#
# Requires installation of MozRepl from CPAN, Firefox, Zotero, and MozRepl
#                          firefox extension, and the biblatex-chicago importer.
#
# The bibtex file will be output to stdout

use strict;
use warnings;

use File::Temp qw/ tempfile/;
use MozRepl;

# temporary file to store bibliography
(undef,my $filename) = tempfile();

my $collectionKey = "3G43MVHQ";

my $repl = MozRepl->new;
# Make it quiet
$repl->setup_log([qw/error fatal/]);
$repl->setup;

# Set the timeout to 60 seconds
$repl->client->{telnet}->timeout(60);
my $executestring = "filename = '$filename';";
$executestring .= q|
var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
file.initWithPath(filename);
var zotero = Components.classes['@zotero.org/Zotero;1'].getService(Components.interfaces.nsISupports).wrappedJSObject;
var translatorObj = new Zotero.Translate('export');
translatorObj.setLocation(file);
//I (Ben Schmidt) changed this to use my biblatex-chicago exporter instead.
//translatorObj.setTranslator('9cb70025-a888-4a29-a210-93ec52da40d4');
translatorObj.setTranslator('ba905f1a-436b-4b6d-a816-ba0b4ac4c9ad');
translatorObj.setCollection(Zotero.Collections.getByKey('| . $collectionKey . q|'));
translatorObj.translate();|;

$repl->execute($executestring);

# print to stdout
open(FH, $filename) or die "Can't open $filename: $!";
foreach(<FH>){
print;
}
print "\n";
close(FH);
# delete the temporary file
unlink($filename);
