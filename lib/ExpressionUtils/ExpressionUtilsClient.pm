package ExpressionUtils::ExpressionUtilsClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

ExpressionUtils::ExpressionUtilsClient

=head1 DESCRIPTION


A KBase module: ExpressionUtils

This module is intended for use by Assemblers to upload RNASeq Expression files
(gtf, fpkm and ctab). This module generates the ctab files and tpm data if they are absent.
The expression files are uploaded as a single compressed file.This module also generates
expression levels and tpm expression levels from the input files and saves them in the
workspace object. Once uploaded, the expression files can be downloaded onto an output directory.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => ExpressionUtils::ExpressionUtilsClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my %arg_hash2 = @args;
	if (exists $arg_hash2{"token"}) {
	    $self->{token} = $arg_hash2{"token"};
	} elsif (exists $arg_hash2{"user_id"}) {
	    my $token = Bio::KBase::AuthToken->new(@args);
	    if (!$token->error_message) {
	        $self->{token} = $token->token;
	    }
	}
	
	if (exists $self->{token})
	{
	    $self->{client}->{token} = $self->{token};
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 upload_expression

  $return = $obj->upload_expression($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is an ExpressionUtils.UploadExpressionParams
$return is an ExpressionUtils.UploadExpressionOutput
UploadExpressionParams is a reference to a hash where the following keys are defined:
	destination_ref has a value which is a string
	source_dir has a value which is a string
	alignment_ref has a value which is a string
	genome_ref has a value which is a string
	annotation_id has a value which is a string
	bam_file_path has a value which is a string
	data_quality_level has a value which is an int
	original_median has a value which is a float
	description has a value which is a string
	platform has a value which is a string
	source has a value which is a string
	external_source_date has a value which is a string
	processing_comments has a value which is a string
UploadExpressionOutput is a reference to a hash where the following keys are defined:
	obj_ref has a value which is a string

</pre>

=end html

=begin text

$params is an ExpressionUtils.UploadExpressionParams
$return is an ExpressionUtils.UploadExpressionOutput
UploadExpressionParams is a reference to a hash where the following keys are defined:
	destination_ref has a value which is a string
	source_dir has a value which is a string
	alignment_ref has a value which is a string
	genome_ref has a value which is a string
	annotation_id has a value which is a string
	bam_file_path has a value which is a string
	data_quality_level has a value which is an int
	original_median has a value which is a float
	description has a value which is a string
	platform has a value which is a string
	source has a value which is a string
	external_source_date has a value which is a string
	processing_comments has a value which is a string
UploadExpressionOutput is a reference to a hash where the following keys are defined:
	obj_ref has a value which is a string


=end text

=item Description

Uploads the expression  *

=back

=cut

 sub upload_expression
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function upload_expression (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to upload_expression:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'upload_expression');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "ExpressionUtils.upload_expression",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'upload_expression',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method upload_expression",
					    status_line => $self->{client}->status_line,
					    method_name => 'upload_expression',
				       );
    }
}
 


=head2 download_expression

  $return = $obj->download_expression($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is an ExpressionUtils.DownloadExpressionParams
$return is an ExpressionUtils.DownloadExpressionOutput
DownloadExpressionParams is a reference to a hash where the following keys are defined:
	source_ref has a value which is a string
DownloadExpressionOutput is a reference to a hash where the following keys are defined:
	destination_dir has a value which is a string

</pre>

=end html

=begin text

$params is an ExpressionUtils.DownloadExpressionParams
$return is an ExpressionUtils.DownloadExpressionOutput
DownloadExpressionParams is a reference to a hash where the following keys are defined:
	source_ref has a value which is a string
DownloadExpressionOutput is a reference to a hash where the following keys are defined:
	destination_dir has a value which is a string


=end text

=item Description

Downloads expression *

=back

=cut

 sub download_expression
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function download_expression (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to download_expression:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'download_expression');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "ExpressionUtils.download_expression",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'download_expression',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method download_expression",
					    status_line => $self->{client}->status_line,
					    method_name => 'download_expression',
				       );
    }
}
 


=head2 export_expression

  $output = $obj->export_expression($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is an ExpressionUtils.ExportParams
$output is an ExpressionUtils.ExportOutput
ExportParams is a reference to a hash where the following keys are defined:
	source_ref has a value which is a string
ExportOutput is a reference to a hash where the following keys are defined:
	shock_id has a value which is a string

</pre>

=end html

=begin text

$params is an ExpressionUtils.ExportParams
$output is an ExpressionUtils.ExportOutput
ExportParams is a reference to a hash where the following keys are defined:
	source_ref has a value which is a string
ExportOutput is a reference to a hash where the following keys are defined:
	shock_id has a value which is a string


=end text

=item Description

Wrapper function for use by in-narrative downloaders to download expressions from shock *

=back

=cut

 sub export_expression
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function export_expression (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to export_expression:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'export_expression');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "ExpressionUtils.export_expression",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'export_expression',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method export_expression",
					    status_line => $self->{client}->status_line,
					    method_name => 'export_expression',
				       );
    }
}
 


=head2 get_expressionMatrix

  $return = $obj->get_expressionMatrix($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is an ExpressionUtils.getExprMatrixParams
$return is an ExpressionUtils.getExprMatrixOutput
getExprMatrixParams is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	output_obj_name has a value which is a string
	expressionset_ref has a value which is a string
getExprMatrixOutput is a reference to a hash where the following keys are defined:
	exprMatrix_FPKM_ref has a value which is a string
	exprMatrix_TPM_ref has a value which is a string

</pre>

=end html

=begin text

$params is an ExpressionUtils.getExprMatrixParams
$return is an ExpressionUtils.getExprMatrixOutput
getExprMatrixParams is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	output_obj_name has a value which is a string
	expressionset_ref has a value which is a string
getExprMatrixOutput is a reference to a hash where the following keys are defined:
	exprMatrix_FPKM_ref has a value which is a string
	exprMatrix_TPM_ref has a value which is a string


=end text

=item Description



=back

=cut

 sub get_expressionMatrix
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_expressionMatrix (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_expressionMatrix:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_expressionMatrix');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "ExpressionUtils.get_expressionMatrix",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_expressionMatrix',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_expressionMatrix",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_expressionMatrix',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "ExpressionUtils.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "ExpressionUtils.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_expressionMatrix',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_expressionMatrix",
            status_line => $self->{client}->status_line,
            method_name => 'get_expressionMatrix',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for ExpressionUtils::ExpressionUtilsClient\n";
    }
    if ($sMajor == 0) {
        warn "ExpressionUtils::ExpressionUtilsClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

A boolean - 0 for false, 1 for true.
@range (0, 1)


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 UploadExpressionParams

=over 4



=item Description

*    Required input parameters for uploading a reads expression data

        string   destination_ref        -   object reference of expression data.
                                            The object ref is 'ws_name_or_id/obj_name_or_id'
                                            where ws_name_or_id is the workspace name or id
                                            and obj_name_or_id is the object name or id
                                            
        string   source_dir             -   directory with the files to be uploaded
        string   alignment_ref          -   alignment workspace object reference
    *


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
destination_ref has a value which is a string
source_dir has a value which is a string
alignment_ref has a value which is a string
genome_ref has a value which is a string
annotation_id has a value which is a string
bam_file_path has a value which is a string
data_quality_level has a value which is an int
original_median has a value which is a float
description has a value which is a string
platform has a value which is a string
source has a value which is a string
external_source_date has a value which is a string
processing_comments has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
destination_ref has a value which is a string
source_dir has a value which is a string
alignment_ref has a value which is a string
genome_ref has a value which is a string
annotation_id has a value which is a string
bam_file_path has a value which is a string
data_quality_level has a value which is an int
original_median has a value which is a float
description has a value which is a string
platform has a value which is a string
source has a value which is a string
external_source_date has a value which is a string
processing_comments has a value which is a string


=end text

=back



=head2 UploadExpressionOutput

=over 4



=item Description

*     Output from upload expression    *


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
obj_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
obj_ref has a value which is a string


=end text

=back



=head2 DownloadExpressionParams

=over 4



=item Description

*
Required input parameters for downloading expression
string source_ref         -       object reference of expression source. The
                            object ref is 'ws_name_or_id/obj_name_or_id'
                            where ws_name_or_id is the workspace name or id
                            and obj_name_or_id is the object name or id
    *


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
source_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
source_ref has a value which is a string


=end text

=back



=head2 DownloadExpressionOutput

=over 4



=item Description

*  The output of the download method.  *


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
destination_dir has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
destination_dir has a value which is a string


=end text

=back



=head2 ExportParams

=over 4



=item Description

*
Required input parameters for exporting expression

string   source_ref         -   object reference of expression source. The
                            object ref is 'ws_name_or_id/obj_name_or_id'
                            where ws_name_or_id is the workspace name or id
                            and obj_name_or_id is the object name or id
     *


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
source_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
source_ref has a value which is a string


=end text

=back



=head2 ExportOutput

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
shock_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
shock_id has a value which is a string


=end text

=back



=head2 getExprMatrixParams

=over 4



=item Description

*
Following are the required input parameters to get Expression Matrix
    *


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
output_obj_name has a value which is a string
expressionset_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
output_obj_name has a value which is a string
expressionset_ref has a value which is a string


=end text

=back



=head2 getExprMatrixOutput

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
exprMatrix_FPKM_ref has a value which is a string
exprMatrix_TPM_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
exprMatrix_FPKM_ref has a value which is a string
exprMatrix_TPM_ref has a value which is a string


=end text

=back



=cut

package ExpressionUtils::ExpressionUtilsClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
