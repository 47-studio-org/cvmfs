#!/bin/sh

# source the common platform independent functionality and option parsing
script_location=$(dirname $(readlink --canonicalize $0))
. ${script_location}/common_test.sh

ut_retval=0
it_retval=0
mg_retval=0

# format additional disks with ext4 and many inodes
echo -n "formatting new disk partitions... "
disk_to_partition=/dev/vda
partition_2=$(get_last_partition_number $disk_to_partition)
partition_1=$(( $partition_2 - 1 ))
format_partition_ext4 $disk_to_partition$partition_1 || die "fail (formatting partition 1)"
format_partition_ext4 $disk_to_partition$partition_2 || die "fail (formatting partition 2)"
echo "done"

# mount additional disk partitions on strategic cvmfs location
echo -n "mounting new disk partitions into cvmfs specific locations... "
mount_partition $disk_to_partition$partition_1 /srv/cvmfs       || die "fail (mounting /srv/cvmfs $?)"
mount_partition $disk_to_partition$partition_2 /var/spool/cvmfs || die "fail (mounting /var/spool/cvmfs $?)"
echo "done"

# running unit test suite
run_unittests --gtest_shuffle || ut_retval=$?

echo "running CernVM-FS test cases..."
cd ${SOURCE_DIRECTORY}/test
./run.sh $TEST_LOGFILE -x src/004-davinci               \
                          src/005-asetup                \
                          src/007-testjobs              \
                          src/024-reload-during-asetup  \
                          src/045-oasis                 \
                          src/5* || it_retval=$?

echo "running CernVM-FS migration test cases..."
./run.sh $MIGRATIONTEST_LOGFILE migration_tests/001-hotpatch || mg_retval=$?

[ $ut_retval -eq 0 ] && [ $it_retval -eq 0 ] && [ $mg_retval -eq 0 ]
