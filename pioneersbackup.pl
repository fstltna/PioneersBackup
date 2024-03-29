#!/usr/bin/perl

# Set these for your situation
my $PIONEERSDIR = "/root/OurPioneers /usr/games/pioneers /usr/share/games/pioneers /usr/share/doc/pioneers /usr/share/gnome/help/pioneers /usr/share/pixmaps/pioneers";
my $BACKUPDIR = "/root/backups";
my $TARCMD = "/bin/tar czf";
my $VERSION = "1.0";

# Init file data
my $MySettings = "$ENV{'HOME'}/.pioneersbackuprc";
my $BACKUPUSER = "";
my $BACKUPPASS = "";
my $BACKUPSERVER = "";
my $BACKUPPATH = "";
my $DEBUG_MODE = "off";

#-------------------
# No changes below here...
#-------------------

sub ReadConfigFile
{
	# Check for config file
	if (-f $MySettings)
	{
		# Read in settings
		open (my $FH, "<", $MySettings) or die "Could not read default file '$MySettings' $!";
		while (<$FH>)
		{
			chop();
			my ($Command, $Setting) = split(/=/, $_);
			if ($Command eq "backupuser")
			{
				$BACKUPUSER = $Setting;
			}
			if ($Command eq "backuppass")
			{
				$BACKUPPASS = $Setting;
			}
			if ($Command eq "backupserver")
			{
				$BACKUPSERVER = $Setting;
			}
			if ($Command eq "backuppath")
			{
				$BACKUPPATH = $Setting;
			}
			if ($Command eq "debugmode")
			{
				$DEBUG_MODE = $Setting;
			}
		}
		close($FH);
	}
	else
	{
		# Store defaults
		open (my $FH, ">", $MySettings) or die "Could not create default file '$MySettings' $!";
		print $FH "backupuser=\n";
		print $FH "backuppass=\n";
		print $FH "backupserver=\n";
		print $FH "backuppath=\n";
		print $FH "debugmode=off\n";
		close($FH);
	}
}

sub PrintDebugCommand
{
	if ($DEBUG_MODE eq "off")
	{
		return;
	}
	my $PassedString = shift;
	print "About to run:\n$PassedString\n";
	print "Press Enter To Run This:";
	my $entered = <STDIN>;
}

ReadConfigFile();

print "PioneersBackup - back up your Pioneers Server - version $VERSION\n";
print "=================================================================\n";

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/pioneersbackup-5.tgz")
{
	unlink("$BACKUPDIR/pioneersbackup-5.tgz")  or warn "Could not unlink $BACKUPDIR/pioneersbackup-5.tgz: $!";
}
if (-f "$BACKUPDIR/pioneersbackup-4.tgz")
{
	rename("$BACKUPDIR/pioneersbackup-4.tgz", "$BACKUPDIR/pioneersbackup-5.tgz");
}
if (-f "$BACKUPDIR/pioneersbackup-3.tgz")
{
	rename("$BACKUPDIR/pioneersbackup-3.tgz", "$BACKUPDIR/pioneersbackup-4.tgz");
}
if (-f "$BACKUPDIR/pioneersbackup-2.tgz")
{
	rename("$BACKUPDIR/pioneersbackup-2.tgz", "$BACKUPDIR/pioneersbackup-3.tgz");
}
if (-f "$BACKUPDIR/pioneersbackup-1.tgz")
{
	rename("$BACKUPDIR/pioneersbackup-1.tgz", "$BACKUPDIR/pioneersbackup-2.tgz");
}
print "Done\nCreating Backup: ";
system("$TARCMD $BACKUPDIR/pioneersbackup-1.tgz $PIONEERSDIR");
if ($BACKUPSERVER ne "")
{
	print "Offsite backup requested\n";
	print "Copying $BACKUPDIR/pioneersbackup-1.tgz to $BACKUPSERVER:$BACKUPPORT\n";
	PrintDebugCommand("rsync -avz -e ssh $BACKUPDIR/pioneersbackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH\n");
	system ("rsync -avz -e ssh $BACKUPDIR/pioneersbackup-1.tgz $BACKUPUSER\@$BACKUPSERVER:$BACKUPPATH");
}

print("Done!\n");
exit 0;
