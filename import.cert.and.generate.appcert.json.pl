#!/usr/bin/perl -W
# 
#
use lib "$ENV{CIOM_SCRIPT_HOME}";
use strict;
use English;
use Data::Dumper;
use Cwd;
use CiomUtil;
use JSON::Parse 'json_file_to_perl';
use JSON;
use String::Escape 'escape';
use open ":encoding(utf8)";
use open IN => ":encoding(utf8)", OUT => ":utf8";
use IO::Handle;

STDOUT->autoflush(1);

our $ciomUtil = new CiomUtil(1);
our $appName = $ARGV[0];
our @orgs;
our $certInfo = {};
our $oldCertInfo = {};
our $iosHost = "172.17.125.213";
our $provisionReader = "/usr/local/bin/mobileprovision-read";
our $appCertRoot= "/Users/ciom/ciomws/wsappcert/$appName";
our @validIdentitiesList;
#our $certPwd = "";
our $SshInfo = {
	port => '22',
	user => 'ciom',
	host => '172.17.125.213'
};

sub writeJsonToFile($$) {
	my $data = shift;
	my $fileName = shift;  
	my $json = new JSON;
	$json->pretty->encode ($data);
	open my $fh, ">", $fileName;
	#print $fh encode_json($data);
	print $fh $json->pretty->encode($data);
	close $fh;
	print $json->pretty->encode($data);
}

sub getOrgs(){
	my $path="$ENV{CIOM_APPCERT_HOME}/$appName"; #设置查询的目录
	opendir(TEMPDIR, $path) or die "can't open it:$!";
	@orgs = grep(!/^\.\.?$/,readdir TEMPDIR); #-d表示选出目录文件，还可以换成其它表达式
	close TEMPDIR;
	@orgs = grep(!/^cert\.json/,@orgs);
}

sub getOldJsonInfo(){
	my $path="$ENV{CIOM_APPCERT_HOME}/$appName/cert.json"; #设置查询的目录
	if ( -e $path ){
		$oldCertInfo = json_file_to_perl("$path");
	} 
	
}

sub generateCertInfo(){
    foreach (@orgs) {
        my $certDetail = {};
    	my $orgCode = $_;
    	if ( -e "$ENV{CIOM_APPCERT_HOME}/$appName/$orgCode/$orgCode.mobileprovision" ) {
    		my $outSubject = getP12Subject($orgCode);
        	$certDetail->{certname}=getP12SubjectO($outSubject);
            #$certDetail->{certname}=rmtGetTeamNameForOrg($orgCode);
            $certDetail->{UID}=getP12SubjectUid($outSubject);
            $certDetail->{CN}=getP12SubjectCN($outSubject);
            $certDetail->{uuid}=rmtGetUUIDForOrg($orgCode);
            $certDetail->{ProfileSpecifier}=rmtGetProfileSpecifierForOrg($orgCode);
            $certDetail->{appId}=rmtGetApplictionIdentifierForOrg($orgCode);
            $certDetail->{p12md5sum}=getP12Md5sumForOrg($orgCode);
        }
        else {
            $certDetail->{certname}="";
            $certDetail->{uuid}="";
            $certDetail->{UID}="";
            $certDetail->{CN}="";
            $certDetail->{ProfileSpecifier}="";
            $certDetail->{p12md5sum}="";
            $certDetail->{appId}="";
        }
    	$certInfo->{$_}=$certDetail ;

    }
}

sub generateAppCertJson(){
	writeJsonToFile($certInfo,"cert.json");
}

sub enterAppCertHome(){
	#$ciomUtil->exec("cd $ENV{CIOM_APPCERT_HOME}/$appName");
	chdir("$ENV{CIOM_APPCERT_HOME}/$appName");
}


sub rmtGetUUIDForOrg($){
	my $code = $_[0];
	my $cmd="ssh ciom\@$iosHost \"$provisionReader -f $appCertRoot/$code/$code.mobileprovision -o UUID\"";
	#print $cmd;
	my @cmdoutput=readpipe($cmd);
	my $uuid = "@cmdoutput";
	chomp($uuid);
	return $uuid;
}

sub rmtGetTeamNameForOrg($){
	my $code = $_[0];
	my $cmd="ssh ciom\@$iosHost \"$provisionReader -f $appCertRoot/$code/$code.mobileprovision -o TeamName\"";
	#print $cmd;
	my @cmdoutput=readpipe($cmd);
	my $teamname = "@cmdoutput";
	chomp($teamname);
	return $teamname;
}

sub rmtGetProfileSpecifierForOrg($){
	my $code = $_[0];
	my $cmd="ssh ciom\@$iosHost \"$provisionReader -f $appCertRoot/$code/$code.mobileprovision -o Name\"";
	#print $cmd;
	my @cmdoutput=readpipe($cmd);
	my $name = "@cmdoutput";
	chomp($name);
	return $name;
}

sub rmtGetApplictionIdentifierForOrg($){
	my $code = $_[0];
	my $cmd="ssh ciom\@$iosHost \"$provisionReader -f $appCertRoot/$code/$code.mobileprovision -o Entitlements.application-identifier\"";
	#print $cmd;
	my @cmdoutput=readpipe($cmd);
	my $appId = "@cmdoutput";
	chomp($appId);
	return $appId;
}

sub getP12Md5sumForOrg($){
	my $code = $_[0];
	my $p12md5 = qx(md5sum $ENV{CIOM_APPCERT_HOME}/$appName/$code/$code-key.p12|cut -d ' ' -f1);
	chomp($p12md5);
	return $p12md5;
}

sub getP12Subject($){
	# will get the O field like as below:
	#subject= /UID=.../CN=.../OU=.../O=GUANGDONG ALPHA ANIMATION & CULTURE CO., LTD./C=...
	my $code = $_[0];
	my $p12in = "$ENV{CIOM_APPCERT_HOME}/$appName/$code/$code-key.p12";
	my $tempPem = "$ENV{CIOM_APPCERT_HOME}/$appName/$code/temp4getsubj.pem";
	my $certPwd = getCertPwdFromFile($code);
	qx(openssl pkcs12 -in $p12in -out $tempPem -passin pass:$certPwd -passout pass:123456 >/dev/null 2>&1);
	my $output = qx(openssl x509 -in $tempPem -inform pem -noout -subject);
	#print $output;
	return $output;
}

sub getP12SubjectO($){
	my $outSub = $_[0];
	$outSub =~/(.*)O=(.*)\/(.*)/;
	return $2;
}

sub getP12SubjectUid($){
	my $outSub = $_[0];
	$outSub =~/\/UID=(.*)\/CN(.*)/;
	return $1;
}

sub getP12SubjectCN($){
	my $outSub = $_[0];
	$outSub =~/(.*)CN=(.*)\/OU(.*)/;
	return $2;
}

sub syncAppCertFilesToAgent(){
	$ciomUtil->execNotLogCmd("rsync -rlptoDz --exclude .svn --delete --force $ENV{CIOM_APPCERT_HOME}/$appName/ $ENV{CIOM_SLAVE_OSX_WORKSPACE}/wsappcert/$appName");
}

sub replaceCertJsonToAgent(){
	$ciomUtil->execNotLogCmd("cp -r $ENV{CIOM_APPCERT_HOME}/$appName/cert.json $ENV{CIOM_SLAVE_OSX_WORKSPACE}/wsappcert/$appName/cert.json");
}

sub revertAppCertHome(){
    my $username = "jenkins";
    my $password = "pwdasdwx";
    my $cmdSvnPrefix = "svn --non-interactive --username $username --password '$password'";
	$ciomUtil->exec("$cmdSvnPrefix revert -R .");
	$ciomUtil->exec("$cmdSvnPrefix update");
}

sub outputCertJson(){
	writeJsonToFile($certInfo,"cert.json");
}

sub getIosAgentValidIndentitiesList(){
	my $cmd="ssh ciom\@$iosHost \"security find-identity -v -p codesigning\"";
	@validIdentitiesList = readpipe($cmd);
	#print "@validIdentitiesList";
	#print "\n";
}

sub isCertImported($) {
	my $code = $_[0];
	my $certTeamName = rmtGetTeamNameForOrg($code);
	my $row;
	for $row (@validIdentitiesList) { 
		if (index($row, $certTeamName) != -1)  {
		    return "certImported";
		}
	}
	return "certNotImported";
}

sub checkCertficateFiles($) {
	my $code = $_[0];
	if ( ! -e "$ENV{CIOM_APPCERT_HOME}/$appName/$code/$code-key.p12" ){
		print "Certfile not exist for org<$code>\n";
		return "p12NotExist";
	} 
	if ( ! -e "$ENV{CIOM_APPCERT_HOME}/$appName/$code/$code.mobileprovision" ){
		print "Mobileprovision not exist for org<$code>\n";
		return "provisionFileNotExist";
	}
	if ( ! -e "$ENV{CIOM_APPCERT_HOME}/$appName/$code/$code-key-password.txt" ){
		print "Certificate password file not exist for org<$code>\n";
		return "pwdFileNotExist";
	} 
	return "certFilesExist";
}

sub getCertPwdFromFile($) {
	my $code = $_[0];
	my $file = "$ENV{CIOM_APPCERT_HOME}/$appName/$code/$code-key-password.txt"; # 将 File 改成你的档案路径.
	open(FILE, $file) or die "Can't open file '$file' for read. $!" ;
    my $line = <FILE>; #读一行
	close FILE;
	my $certPwd = "";
	if ($line) {
		chomp($line);
		$line=~s/^\s+|\s+$//g;
		if($line ne ''){
			#print "$line\n";
			$certPwd = $line;
			#print "password is: $certPwd\n";
			return $certPwd;
		}
	}
	#print "password is empty\n";
	return $certPwd;

}

sub importCertificateForOrg($) {
	my $code = $_[0];
	my $certExist = isCertImported($code); 
	my $oldP12Md5Sum = $oldCertInfo->{$code}->{p12md5sum};
	my $curP12Md5Sum = getP12Md5sumForOrg($code);
	if ( $certExist eq 'certImported') {
		if ( $curP12Md5Sum eq $oldP12Md5Sum ) {
			print "Certficate already imported for org<$code>.\n";
		} else {
			print "Certficate p12 file changed for org<$code>, need to import.\n";
			remoteImportCertificateForOrg($code);
		}
		
	}
	else {
		print "Certficate not exist, need to import.\n";
		remoteImportCertificateForOrg($code);
	}
}

sub remoteImportCertificateForOrg($) {
	my $code = $_[0];
	my $certPwd = getCertPwdFromFile($code);
	my $certFilesStatus = checkCertficateFiles($code); 
	my $sshUser = $SshInfo->{user};
	my $uuid = $certInfo->{$code}->{uuid};
	my $cmdImportMobileProvision = "cp -r /Users/$sshUser/ciomws/wsappcert/$appName/$code/$code.mobileprovision /Users/$sshUser/Library/Mobiledevice/Provisioning\\ Profiles/$uuid.mobileprovision";

	if ( $certPwd ne '') {
		my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/$sshUser/Library/Keychains/login.keychain";
		my $cmdImportCert = "security import $appCertRoot/$code/$code-key.p12 -k ~/Library/Keychains/login.keychain -P $certPwd";
		$SshInfo->{cmd} = "( $cmdUnlockKeychain; $cmdImportCert; $cmdImportMobileProvision )";
		
	}
	else {
		my $cmdP12ToPem = "openssl pkcs12 -in $appCertRoot/$code/$code-key.p12 -out $appCertRoot/$code/temp.pem -passin pass: -passout pass:123456";
		my $cmdPemBackToP12WithPWd = "openssl pkcs12 -export -in $appCertRoot/$code/temp.pem -out $appCertRoot/$code/cert-final.p12 -passin pass:123456 -passout pass:123456";
		my $cmdUnlockKeychain = "security -v unlock-keychain -p pwdasdwx /Users/$sshUser/Library/Keychains/login.keychain";
		my $cmdImportCert = "security import $appCertRoot/$code/cert-final.p12 -k ~/Library/Keychains/login.keychain -P 123456";
		$SshInfo->{cmd} = "( $cmdP12ToPem; $cmdPemBackToP12WithPWd; $cmdUnlockKeychain; $cmdImportCert; $cmdImportMobileProvision )";
		#$SshInfo->{cmd} = "( $cmdPemBackToP12WithPWd; $cmdUnlockKeychain; $cmdImportCert; $cmdImportMobileProvision )";
	}

	$ciomUtil->remoteExec($SshInfo);
}

sub importCertificate() {
	foreach (@orgs) {
		my $orgCode = $_;
		print "========   Start for org<$orgCode>   ========\n";
		my $certFilesStatus = checkCertficateFiles($orgCode); 
		if ( $certFilesStatus eq 'certFilesExist') {
			importCertificateForOrg($orgCode); 
		}
		print "========    End for org<$orgCode>    ========\n\n\n";
	}
}

sub main(){
	enterAppCertHome();
	revertAppCertHome();
	getOldJsonInfo();
	getOrgs();
	getIosAgentValidIndentitiesList();
	syncAppCertFilesToAgent();
	generateCertInfo();
	importCertificate();
	outputCertJson();
}

main();
