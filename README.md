# Bio-ReferenceManager
Add references to tracking system

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/sanger-pathogens/Bio-ReferenceManager/blob/master/GPL-LICENSE)   

## Contents
  * [Introduction](#introduction)
  * [Installation](#installation)
    * [From Source](#from-source)
    * [Running the tests](#running-the-tests)
  * [Usage](#usage)
  * [License](#license)
  * [Feedback/Issues](#feedbackissues)

## Introduction
Scripts for managing reference files in tracking system.

## Installation
Bio-ReferenceManager has the following dependencies:

### Required dependencies
* dos2unix
* fastaq
* smalt
* bwa
* bowtie2
* samtools
* Picard
* rsync

Details for installing Bio-ReferenceManager are provided below. If you encounter an issue when installing Bio-ReferenceManager please contact your local system administrator. If you encounter a bug please log it [here](https://github.com/sanger-pathogens/Bio-ReferenceManager/issues) or email us at path-help@sanger.ac.uk.

### From Source
Clone the repository:

`git clone https://github.com/sanger-pathogens/Bio-ReferenceManager.git`

Move into the directory and install all dependencies using [DistZilla](http://dzil.org/):

```
cd Bio-ReferenceManager
dzil authordeps --missing | cpanm
dzil listdeps --missing | cpanm
```

Run the tests:

`dzil test`
If the tests pass, install Bio-ReferenceManager:

`dzil install`

### Running the tests
The test can be run with dzil from the top level directory:

`dzil test`

## Usage
```
Usage: refman [options] *.fa
Add references to the pipelines.

Options: -o       overwrite index files [False]
         -p INT   number of processors [1]
         -r STR   reference store directory [/nfs/pathogen/refs]
         -d STR   production references direcotry [/lustre/scratch118/.../refs]
         -m STR   reference metadata filename [metadata.json]
         -n       use a hash of the file as the reference name [FALSE]
         -i STR   toplevel index filename [refs.index]
         -a       Dont annotate with Prokka [FALSE]
         -v       verbose output to STDOUT
         -h       this help message

Advanced options:
         --java_exec     STR  java executable [java]
         --dos2unix_exec STR  dos2unix executable [dos2unix]
         --fastaq_exec   STR  fastaq executable [fastaq]
```
## License
Bio-ReferenceManager is free software, licensed under [GPLv3](https://github.com/sanger-pathogens/Bio-ReferenceManager/blob/master/GPL-LICENSE).

## Feedback/Issues
Please report any issues to the [issues page](https://github.com/sanger-pathogens/Bio-ReferenceManager/issues) or email path-help@sanger.ac.uk.