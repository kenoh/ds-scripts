#!/bin/bash
set -x
set -e


install-deps () {
	grep -E "^(Build)?Requires" rpm/389-ds-base.spec.in \
		  | grep -v -E '(name|MODULE)' \
		  | awk '{ print $2 }' \
		  | sed 's/%{python3_pkgversion}/3/g' \
		  | grep -v "^/" \
		  | grep -v pkgversion \
		  | sort | uniq \
		  | tr '\n' ' ' \
		| xargs sudo dnf -y install --setopt=strict=False
}


srpms () {
	make -f rpm.mk clean
	make -f rpm.mk srpms
}


reinstall-from () {
	pushd "$1"
	sudo dnf -y remove '389-ds-base*' 'python3-lib389' 'python3-389-ds-base-tests'
	sudo dnf -y install */*.rpm
	popd
}


rpms () {
	srpms

	ts=$(date --utc +%Y%m%d_%H%M%SZ)
	mv ~/rpmbuild/RPMS{,~$ts} || true
	rpmbuild --nocheck --rebuild dist/srpms/*

	reinstall-from ~/rpmbuild/RPMS
}


debug-spec () {
	SPEC="rpm/389-ds-base.spec.in"
	stat "$SPEC"
	sed -i '/^autoreconf/i export CFLAGS="$CFLAGS -O0"' "$SPEC"
}


if [ 'function' = `LC_ALL=C type -t "$1"` ]; then
	CMD="$1"
	shift
	"$CMD" "${@}"
else
	echo "Unknown command: $1" > /dev/stderr
fi
