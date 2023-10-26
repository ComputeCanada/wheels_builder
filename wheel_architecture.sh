#!/bin/bash

filename=$1
fullname=$(readlink -f $filename)

tmp=$(mktemp --directory)
cd $tmp
WORKS_ON_GENTOO2020=1
WORKS_ON_GENTOO2023=1
WORKS_ON_NIX=1

# On Nix we don't have Py 3.9 and newer so those wheels can be generic and don't need
# to be checked for Nix compatibility
NEWER_PYTHON_REGEXP='computecanada-cp3[91]'
if [[ $fullname =~ $NEWER_PYTHON_REGEXP ]]; then
	WORKS_ON_NIX=0
fi

unzip -qn $fullname
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
GENTOO2020_GLIBC="/cvmfs/soft.computecanada.ca/gentoo/2020/lib64/libc.so.6"
GENTOO2023_GLIBC="/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/lib64/libc.so.6"
NIX_LDD="/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/ldd"
GENTOO2020_LDD="/cvmfs/soft.computecanada.ca/gentoo/2020/usr/bin/ldd"
GENTOO2023_LDD="/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3/usr/bin/ldd"
NIX_GLIBC_VERSION=$(strings "$NIX_GLIBC" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
GENTOO2020_GLIBC_VERSION=$(strings "$GENTOO2020_GLIBC" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
GENTOO2023_GLIBC_VERSION=$(strings "$GENTOO2023_GLIBC" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)

self_contained_shared_objects=$(find . -name '*.so*' -print0 | xargs -0 -n1 -- basename 2>/dev/null | tr '\n' '|' | sed -e "s/|$//g")

OIFS="$IFS"
IFS=$'\n'
for fname in $(find . -type f); do
	filetype=$(file -b "$fname")
	rpath=''
	interpreter=''
	min_required_glibc=''
	if [[ $filetype =~ $REX_DYNAMIC ]]; then
		if [[ $filetype =~ $REX_OS_INTERPRETER || $filetype =~ $REX_LINUX_INTERPRETER || $filetype =~ $REX_LSB_INTERPRETER ]]; then
			interpreter=$(patchelf --print-interpreter "$fname")
		fi
		rpath=$(patchelf --print-rpath "$fname")
		min_required_glibc=$(strings "$fname" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
	elif [[ $filetype =~ $REX_SO ]]; then
		rpath=$(patchelf --print-rpath "$fname")
		min_required_glibc=$(strings "$fname" | grep "^GLIBC_" | cut -d'_' -f2 | sort -V | grep "^[0-9]" | tail -1)
	else
		continue
	fi

	# remove rpath from python itself from consideration
	rpath=$(echo $rpath | sed -e "s;[^:]*/Core/python[^:]*;;g")
	
	if [[ $WORKS_ON_NIX -eq 1 && $rpath =~ 'nix' || $rpath =~ 'easybuild/software/2017' ]]; then
		WORKS_ON_GENTOO2020=0
		WORKS_ON_GENTOO2023=0
		echo "$fname" is nix, rpath=$rpath  >&2
	elif [[ $rpath =~ 'gentoo/2020' || $rpath =~ 'easybuild/software/2020' || $rpath =~ 'easybuild/software/2019' ]]; then
		WORKS_ON_NIX=0
		WORKS_ON_GENTOO2023=0
		echo "$fname" is gentoo2020, rpath=$rpath  >&2
	elif [[ $rpath =~ 'gentoo/2023' || $rpath =~ 'easybuild/software/2023' || "$EBVERSIONGENTOO" == "2023" ]]; then
		WORKS_ON_NIX=0
		WORKS_ON_GENTOO2020=0
		echo "$fname" is gentoo2023, rpath=$rpath  >&2
	fi
	if [[ $WORKS_ON_NIX -eq 1 && "$(version_lte $min_required_glibc $NIX_GLIBC_VERSION)" == "no" ]]; then
		WORKS_ON_NIX=0
		echo "$fname" requires a glibc more recent than that provided by Nix: $min_required_glibc ">" $NIX_GLIBC_VERSION >&2
	fi
	if [[ "$(version_lte $min_required_glibc $GENTOO2020_GLIBC_VERSION)" == "no" ]]; then
		WORKS_ON_GENTOO2020=0
		echo "$fname" requires a glibc more recent than that provided by Gentoo 2020: $min_required_glibc ">" $GENTOO2020_GLIBC_VERSION >&2
	fi
	if [[ "$(version_lte $min_required_glibc $GENTOO2023_GLIBC_VERSION)" == "no" ]]; then
		WORKS_ON_GENTOO2023=0
		echo "$fname" requires a glibc more recent than that provided by Gentoo 2023: $min_required_glibc ">" $GENTOO2020_GLIBC_VERSION >&2
	fi
	if [[ $WORKS_ON_NIX -eq 1 ]]; then
		$NIX_LDD "$fname" | grep -E -v $self_contained_shared_objects | grep "not found" >&2
		NIX_HAVE_LIBS=$?
	fi
	$GENTOO2020_LDD "$fname" | grep -E -v $self_contained_shared_objects | grep "not found" >&2
	GENTOO2020_HAVE_LIBS=$?
	$GENTOO2023_LDD "$fname" | grep -E -v $self_contained_shared_objects | grep "not found" >&2
	GENTOO2023_HAVE_LIBS=$?
	if [[ $WORKS_ON_NIX -eq 1 && $NIX_HAVE_LIBS -eq 0 ]]; then
		WORKS_ON_NIX=0
		echo "$fname" is missing some libraries in Nix >&2
	fi
	if [[ $GENTOO2020_HAVE_LIBS -eq 0 ]]; then
		WORKS_ON_GENTOO2020=0
		echo "$fname" is missing some libraries in Gentoo 2020 >&2
	fi
	if [[ $GENTOO2023_HAVE_LIBS -eq 0 ]]; then
		WORKS_ON_GENTOO2023=0
		echo "$fname" is missing some libraries in Gentoo 2023 >&2
	fi
	if [[ $WORKS_ON_GENTOO2020 -eq 1 && $WORKS_ON_GENTOO2023 -eq 1 ]]; then
		if [[ $WORKS_ON_NIX -eq 1 || $filename =~ $NEWER_PYTHON_REGEXP ]]; then
			COMPATIBILITY_LAYER="generic"
		else
			COMPATIBILITY_LAYER="gentoo"
		fi
	elif [[ $WORKS_ON_GENTOO2023 -eq 1 ]]; then
		COMPATIBILITY_LAYER="gentoo2023"
	elif [[ $WORKS_ON_GENTOO2020 -eq 1 ]]; then
		COMPATIBILITY_LAYER="gentoo2020"
	elif [[ $WORKS_ON_NIX -eq 1 ]]; then
		COMPATIBILITY_LAYER="nix"
	else
		COMPATIBILITY_LAYER="unknown"
	fi

	if [[ $rpath =~ '/sse3/' && $ARCHITECTURE == "generic" ]]; then
		ARCHITECTURE='sse3'
		echo "$fname" is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/avx/' && ($ARCHITECTURE == "generic" || $ARCHITECTURE == "sse3") ]]; then
		ARCHITECTURE="avx"
		echo "$fname" is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/avx2/' && ($ARCHITECTURE == "generic" || $ARCHITECTURE == "sse3" || $ARCHITECTURE == "avx") ]]; then
		ARCHITECTURE="avx2"
		echo "$fname" is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/avx512/' ]]; then
		ARCHITECTURE="avx512"
		echo "$fname" is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/x86-64-v3/' ]]; then
		ARCHITECTURE="x86-64-v3"
		echo "$fname" is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	elif [[ $rpath =~ '/x86-64-v4/' ]]; then
		ARCHITECTURE="x86-64-v4"
		echo "$fname" is $COMPATIBILITY_LAYER $ARCHITECTURE, rpath=$rpath  >&2
	fi
done
IFS="$OIFS"

cd - &> /dev/null
rm -rf $tmp
echo $COMPATIBILITY_LAYER $ARCHITECTURE
