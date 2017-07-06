package Bio::ReferenceManager::PrepareFasta;

# ABSTRACT: Take in a fasta file, fix it up, save it

=head1 SYNOPSIS

Take in a fasta file, fix it up, save it

=cut

use Moose;
use File::Copy;
use File::Temp;
use File::Basename;
use Cwd qw(abs_path getcwd);
use File::Path qw(make_path);
use Bio::SeqIO;
use JSON;
use File::Slurper 'write_text';
use Digest::MD5::File qw(file_md5_hex);
use Bio::ReferenceManager::Reference;
with 'Bio::ReferenceManager::CommandLine::LoggingRole';

has 'fasta_file'             => ( is => 'ro', isa => 'Str',  required => 1 );
has 'reference_store_dir'    => ( is => 'rw', isa => 'Str',  required => 1 );
has 'name_as_hash'           => ( is => 'rw', isa => 'Bool', default  => 1 );
has 'hash_toplevel_dir_name' => ( is => 'rw', isa => 'Str',  default  => 'hash' );

has 'reference_output_directory' => ( is => 'rw', isa => 'Maybe[Str]', required => 0 );
has 'relative_directory'         => ( is => 'rw', isa => 'Maybe[Str]', required => 0 );

has 'dos2unix_exec' => ( is => 'rw', isa => 'Str', default => 'dos2unix' );
has 'fastaq_exec'   => ( is => 'rw', isa => 'Str', default => 'fastaq' );

has '_tmp_dir_object' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_tmp_dir' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__tmp_dir' );

has 'reference' => ( is => 'rw', isa => 'Bio::ReferenceManager::Reference', default => sub { Bio::ReferenceManager::Reference->new(); } );

sub _build__tmp_dir {
    my ($self) = @_;
    return $self->_tmp_dir_object->dirname();
}

sub fix_file_and_save {
    my ($self) = @_;
    $self->_run_dos2unix();
    $self->is_valid_fasta( $self->_dos2unix_output_filename );
    $self->_run_acgtn_only();
    $self->_fix_sequence_names();
    $self->_run_sort_by_name();

    my $md5 = file_md5_hex( $self->_sort_by_name_output_filename );
    $self->logger->info( "MD5 for " . $self->fasta_file . ": $md5" );

    my $final_outputname;
    if ( $self->name_as_hash ) {
        $final_outputname = $self->md5_final_output_filename($md5);
    }
    else {
        $final_outputname = $self->basename_final_output_filename();
    }

    $self->logger->info( "Copy file " . $self->_sort_by_name_output_filename . " to " . $final_outputname );
    copy( $self->_sort_by_name_output_filename, $final_outputname );

    $self->reference->final_filename($final_outputname);
    $self->reference->original_filename( $self->fasta_file );
    $self->reference->md5($md5);
    $self->reference->relative_directory( $self->relative_directory );
    my ( $filename, $dirs, $suffix ) = fileparse( $final_outputname, qr/\.[^.]*/ );
    $self->reference->basename( $filename, qr/\.[^.]*/ );
}

sub write_metadata_to_json {
    my ( $self, $metadata_filename ) = @_;
    my $outputfile = join( '/', ( $self->reference_output_directory, $metadata_filename ) );
    $self->logger->info( "Writing meta data to JSON file: " . $outputfile );
    write_text( $outputfile, to_json $self->reference->to_hash );
}

sub _dos2unix_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'dos2unix.fa' ) );
}

sub _run_dos2unix {
    my ($self) = @_;
    my $cmd = join( ' ', ( $self->dos2unix_exec, '-n', $self->fasta_file, $self->_dos2unix_output_filename, '> /dev/null 2>&1' ) );

    $self->logger->info("Command for dos2unix: $cmd");

    system($cmd);
    1;
}

sub is_valid_fasta {
    my ( $self, $filename ) = @_;
    my $seqio_obj = Bio::SeqIO->new(
        -file     => $filename,
        -format   => "fasta",
        -alphabet => 'dna'
    );
    my $total_length = 0;
    eval {
        while ( my $seq_obj = $seqio_obj->next_seq ) {
            $total_length += $seq_obj->length();
        }
        $self->reference->sequence_length($total_length);
    };
    $@ ? return 0 : return 1;
}

sub _acgtn_only_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'acgtn_only.fa' ) );
}

sub _run_acgtn_only {
    my ($self) = @_;
    my $cmd = join( ' ', ( $self->fastaq_exec, 'acgtn_only', $self->_dos2unix_output_filename, $self->_acgtn_only_output_filename ) );

    $self->logger->info("Command for fastaq acgtn only: $cmd");

    system($cmd);
    1;
}

sub _sort_by_name_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'sort_by_name.fa' ) );
}

sub _run_sort_by_name {
    my ($self) = @_;
    my $cmd =
      join( ' ', ( $self->fastaq_exec, 'sort_by_name', $self->_fix_sequence_names_output_filename, $self->_sort_by_name_output_filename ) );

    $self->logger->info("Command for fastaq sort by name only: $cmd");

    system($cmd);
    1;
}

sub _fix_sequence_names_output_filename {
    my ($self) = @_;
    return join( '', ( $self->_tmp_dir, '/', 'fix_sequence_names.fa' ) );
}

sub _fix_sequence_names {
    my ($self)           = @_;
    my $sequence_counter = 1;
    my $seqio_obj        = Bio::SeqIO->new(
        -file     => $self->_acgtn_only_output_filename,
        -format   => "fasta",
        -alphabet => 'dna'
    );
    my $seqout = Bio::SeqIO->new( -format => 'Fasta', -file => '>' . $self->_fix_sequence_names_output_filename, -alphabet => 'dna' );

    while ( my $seq_obj = $seqio_obj->next_seq ) {
        my $seq_name = $seq_obj->display_id;
        $seq_name =~ s![\W]!_!gi;
        $seq_obj->display_id( $seq_name . "_" . $sequence_counter );
        $seqout->write_seq($seq_obj);
        $sequence_counter++;
    }

}

sub basename_final_output_filename {
    my ($self) = @_;

    my ( $filename, $dirs, $suffix ) = fileparse( $self->fasta_file, qr/\.[^.]*/ );

    my $genus         = 'unknown';
    my $species       = 'unknown';
    my @genus_species = split( '_', basename($filename) );
    
    
    if(@genus_species == 1)
    {
        $genus = basename($filename);
    }
    elsif(@genus_species > 1)
    {
        $genus = shift @genus_species;
        $species = join('_', @genus_species);
    }

    $self->relative_directory( join( '/', ( $genus, $species ) ) );
    my $directory = join( '/', ( $self->reference_store_dir, $self->relative_directory ) );
    make_path($directory) if ( !-d $directory );
    $self->reference_output_directory( abs_path($directory) );

    my $path = join( '/', ( abs_path($directory), $filename . '.fa' ) );
    $self->logger->info("Final output filename: $path");
    return $path;
}

sub md5_final_output_filename {
    my ( $self, $md5 ) = @_;

    $self->relative_directory( join( '/', ( $self->hash_toplevel_dir_name, $md5 ) ) );
    my $directory = join( '/', ( $self->reference_store_dir, $self->relative_directory ) );

    make_path($directory) if ( !-d $directory );
    $self->reference_output_directory( abs_path($directory) );
    my $path = join( '/', ( abs_path($directory), $md5 . '.fa' ) );
    $self->logger->info("Final output filename MD5: $path");
    return $path;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
