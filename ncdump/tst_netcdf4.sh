#!/bin/sh
# This shell script tests ncdump for netcdf-4
# Ed Hartnett, Dennis Heimbigner

if test "x$srcdir" = x ; then srcdir=`pwd`; fi 
. ../test_common.sh

set -e

echo ""
echo "*** Testing ncgen and ncdump test output for netCDF-4 format."
# echo "*** creating netcdf-4 file c0_4.nc from c0_4.cdl..."
${NCGEN} -k nc4 -b -o c0_4.nc ${ncgenc04}
# echo "*** creating c1_4.cdl from c0_4.nc..."
${NCDUMP} -n c1 c0_4.nc | sed 's/e+0/e+/g' > c1_4.cdl
# echo "*** comparing c1_4.cdl with ref_ctest1_nc4.cdl..."
diff -b c1_4.cdl $srcdir/ref_ctest1_nc4.cdl

echo "*** Testing ncgen and ncdump test output for netCDF-4 classic format."
# echo "*** creating netcdf-4 classic file c0.nc from c0.cdl..."
${NCGEN} -k nc7 -b -o c0.nc ${ncgenc0}
# echo "*** creating c1.cdl from c0.nc..."

echo "*** Testing that program tst_h_rdc0 can read c0.cdl."
${execdir}/tst_h_rdc0

# echo "*** comparing c1.cdl with ref_ctest1_nc4c.cdl..."
diff -b c1.cdl $srcdir/ref_ctest1_nc4c.cdl

echo "*** Running tst_create_files.c to create test files."
${execdir}/tst_create_files
echo "*** Testing tst_create_files output for netCDF-4 features."
${NCDUMP} tst_solar_1.nc | sed 's/e+0/e+/g' > tst_solar_1.cdl
# echo "*** comparing tst_solar_1.cdl with ref_tst_solar_1.cdl..."
diff -b tst_solar_1.cdl $srcdir/ref_tst_solar_1.cdl
${NCDUMP} tst_solar_2.nc | sed 's/e+0/e+/g' > tst_solar_2.cdl
# echo "*** comparing tst_solar_2.cdl with ref_tst_solar_2.cdl..."
diff -b tst_solar_2.cdl $srcdir/ref_tst_solar_2.cdl

echo "*** Running tst_group_data.c to create test files."
${execdir}/tst_group_data
${NCDUMP} tst_group_data.nc | sed 's/e+0/e+/g' > tst_group_data.cdl
# echo "*** comparing tst_group_data.cdl with ref_tst_group_data.cdl..."
diff -b tst_group_data.cdl $srcdir/ref_tst_group_data.cdl

# Temporary hack to skip a couple tests that won't work in windows
# without changing the format of the string. See:
#
# http://www.mingw.org/wiki/Posix_path_conversion

if [[ "$OSTYPE" != 'msys' ]]; then
echo "*** Testing -v option with absolute name and groups..."
${NCDUMP} -v /g2/g3/var tst_group_data.nc | sed 's/e+0/e+/g' > tst_group_data.cdl
# echo "*** comparing tst_group_data.cdl with ref_tst_group_data_v23.cdl..."
diff -b tst_group_data.cdl $srcdir/ref_tst_group_data_v23.cdl
fi

echo "*** Testing -v option with relative name and groups..."
${NCDUMP} -v var,var2 tst_group_data.nc | sed 's/e+0/e+/g' > tst_group_data.cdl
# echo "*** comparing tst_group_data.cdl with ref_tst_group_data.cdl..."
diff -b tst_group_data.cdl $srcdir/ref_tst_group_data.cdl

echo "*** Running tst_enum_data.c to create test files."
${execdir}/tst_enum_data
${NCDUMP} tst_enum_data.nc | sed 's/e+0/e+/g' > tst_enum_data.cdl
# echo "*** comparing tst_enum_data.cdl with ref_tst_enum_data.cdl..."
diff -b tst_enum_data.cdl $srcdir/ref_tst_enum_data.cdl

echo "*** Running tst_opaque_data.c to create test files."
${execdir}/tst_opaque_data
${NCDUMP} tst_opaque_data.nc | sed 's/e+0/e+/g' > tst_opaque_data.cdl
# echo "*** comparing tst_opaque_data.cdl with ref_tst_opaque_data.cdl..."
diff -b tst_opaque_data.cdl $srcdir/ref_tst_opaque_data.cdl

echo "*** Running tst_vlen_data.c to create test files."
${execdir}/tst_vlen_data
${NCDUMP} tst_vlen_data.nc | sed 's/e+0/e+/g' > tst_vlen_data.cdl
# echo "*** comparing tst_vlen_data.cdl with ref_tst_vlen_data.cdl..."
diff -b tst_vlen_data.cdl $srcdir/ref_tst_vlen_data.cdl

echo "*** Running tst_comp.c to create test files."
${execdir}/tst_comp
${NCDUMP} tst_comp.nc | sed 's/e+0/e+/g' > tst_comp.cdl
# echo "*** comparing tst_comp.cdl with ref_tst_comp.cdl..."
diff -b tst_comp.cdl $srcdir/ref_tst_comp.cdl
# echo "*** creating tst_nans.cdl from tst_nans.nc"

echo "*** Running tst_nans.c to create test files."
${execdir}/tst_nans
${NCDUMP} tst_nans.nc | sed 's/e+0/e+/g' > tst_nans.cdl
# echo "*** comparing ncdump of generated file with ref_tst_nans.cdl ..."
diff -b tst_nans.cdl $srcdir/ref_tst_nans.cdl

# Do unicode test only if it exists => BUILD_UTF8 is true
if test -f ./tst_unicode -o -f ./tst_unicode.exe ; then
  echo "*** dumping tst_unicode.nc to tst_unicode.cdl..."
  ${execdir}/tst_unicode
${NCDUMP} tst_unicode.nc | sed 's/e+0/e+/g' > tst_unicode.cdl
  #echo "*** comparing tst_unicode.cdl with ref_tst_unicode.cdl..."
  #diff -b tst_unicode.cdl $srcdir/ref_tst_unicode.cdl
fi

echo "*** Running tst_special_atts.c to create test files."
${execdir}/tst_special_atts
${NCDUMP} -c -s tst_special_atts.nc \
    | sed 's/e+0/e+/g' \
    | sed -e 's/netcdflibversion=.*[|]/netcdflibversion=0.0.0|/' \
    | sed -e 's/hdf5libversion=.*"/hdf5libversion=0.0.0"/' \
    | sed -e 's|_SuperblockVersion = [0-9]|_SuperblockVersion = 0|' \
    | cat > tst_special_atts.cdl
echo "*** comparing tst_special_atts.cdl with ref_tst_special_atts.cdl..."
diff -b tst_special_atts.cdl $srcdir/ref_tst_special_atts.cdl

echo ""
echo "*** Testing ncdump on file with corrupted header "
rm -f ./ignore_tst_netcdf4
if ${NCDUMP} ${srcdir}/ref_test_corrupt_magic.nc > ./ignore_tst_netcdf4 2>&1 ; then
echo "***Fail: ncdump should have failed on ref_test_corrupt_magic.nc"
else
echo "***XFail: ncdump properly failed on ref_test_corrupt_magic.nc"
fi
rm -fr ./ignore_tst_netcdf4

echo "*** All ncgen and ncdump test output for netCDF-4 format passed!"
exit 0
