#!/bin/bash

filename=$1
fullname=$(readlink -f $filename)

tmp=$(mktemp --directory)
cd $tmp

unzip -q $fullname
REX_DYNAMIC="^ELF 64-bit LSB.*dynamically linked.*"
REX_SO="^ELF 64-bit LSB shared object.*x86-64.*"
REX_OS_INTERPRETER=".*interpreter /lib64/ld-linux-x86-64.so.2.*"
REX_LINUX_INTERPRETER=".*interpreter.*ld-linux-x86-64.so.2"
REX_LSB_INTERPRETER=".*interpreter.*ld-lsb-x86-64.so.3"

ARCHITECTURE="generic"
COMPATIBILITY_LAYER="generic"

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
function version_lte {
	printf '%s\n%s' "$1" "$2" | sort -C -V && echo "yes" || echo "no"
}

NIX_GLIBC="/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/lib/libc.so.6"
GENTOO_GLIBC="/cvmfs/soft.computecanada.ca/gentoo/2020/lib64/libc.so.6"
NIX_GLIBC_VERSION=$(strings "$NIX_GLIBC" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
GENTOO_GLIBC_VERSION=$(strings "$GENTOO_GLIBC" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)

for fname in $(find . -type f); do
	filetype=$(file -b $fname)
	rpath=''
	interpreter=''
	min_required_glibc=''
	if [[ $filetype =~ $REX_DYNAMIC ]]; then
		if [[ $filetype =~ $REX_OS_INTERPRETER || $filetype =~ $REX_LINUX_INTERPRETER || $filetype =~ $REX_LSB_INTERPRETER ]]; then
			interpreter=$(patchelf --print-interpreter "$fname")
		fi
		rpath=$(patchelf --print-rpath $fname)
		min_required_glibc=$(strings "$fname" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
	elif [[ $filetype =~ $REX_SO ]]; then
		rpath=$(patchelf --print-rpath $fname)
		min_required_glibc=$(strings "$fname" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
	else
		continue
	fi

	# remove rpath from python itself from consideration
	rpath=$(echo $rpath | sed -e "s;[^:]*/Core/python[^:]*;;g")
	
	if [[ $rpath =~ 'nix' || $rpath =~ 'easybuild/software/2017' ]]; then
		COMPATIBILITY_LAYER='nix'
		echo $fname is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ 'gentoo' || $rpath =~ 'easybuild/software/2020' || $rpath =~ 'easybuild/software/2019' ]]; then
		COMPATIBILITY_LAYER='gentoo'
		echo $fname is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	fi
	if [[ "$(version_lte $min_required_glibc $NIX_GLIBC_VERSION)" == "no" ]]; then
		COMPATIBILITY_LAYER='gentoo'
		echo $fname requires a glibc more recent than that provided by Nix: $min_required_glibc ">" $NIX_GLIBC_VERSION >&2
	fi
	if [[ "$(version_lte $min_required_glibc $GENTOO_GLIBC_VERSION)" == "no" ]]; then
		COMPATIBILITY_LAYER='unknown'
		echo $fname requires a glibc more recent than that provided by Gentoo: $min_required_glibc ">" $GENTOO_GLIBC_VERSION >&2
	fi
	

	if [[ $rpath =~ '/sse3/' && $ARCHITECTURE == "generic" ]]; then
		ARCHITECTURE='sse3'
		echo $fname is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/avx/' && ($ARCHITECTURE == "generic" || $ARCHITECTURE == "sse3") ]]; then
		ARCHITECTURE="avx"
		echo $fname is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/avx2/' && ($ARCHITECTURE == "generic" || $ARCHITECTURE == "sse3" || $ARCHITECTURE == "avx") ]]; then
		ARCHITECTURE="avx2"
		echo $fname is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/avx512/' ]]; then
		ARCHITECTURE="avx512"
		echo $fname is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	fi
done

cd - &> /dev/null
rm -rf $tmp
echo $COMPATIBILITY_LAYER $ARCHITECTURE
