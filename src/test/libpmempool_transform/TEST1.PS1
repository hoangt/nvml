#
# Copyright 2016, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# libpmempool_transform/TEST1w -- test for checking pmempool transform;
#                                 pmem/issues#320
#
[CmdletBinding(PositionalBinding=$false)]
Param(
    [alias("d")]
    $DIR = ""
    )
$Env:UNITTEST_NAME = "libpmempool_transform\TEST1w"
$Env:UNITTEST_NUM = "1w"

. ..\unittest\unittest.ps1

require_test_type medium
require_fs_type any
setup

$LOG="out$Env:UNITTEST_NUM.log"
$LOG_TEMP="out${Env:UNITTEST_NUM}_part.log"
rm $LOG -Force -ea si
touch $LOG
rm $LOG_TEMP -Force -ea si
touch $LOG_TEMP

$LAYOUT="OBJ_LAYOUT"
$POOLSET_IN="$DIR\poolset.in"
$POOLSET_OUT="$DIR\poolset.out"

# Create poolset files
create_poolset $POOLSET_IN `
	20M:$DIR\part00:x `
	20M:$DIR\part01:x

create_poolset $POOLSET_OUT `
	20M:$DIR\part00:x `
	20M:$DIR\part01:x `
	r `
	20M:$DIR\part10:x `
	20M:$DIR\part11:x

# Log poolset structures
echo poolset_in >> $LOG_TEMP
cat $POOLSET_IN >> $LOG_TEMP
echo "" >> $LOG_TEMP
echo poolset_out >> $LOG_TEMP
cat $POOLSET_OUT >> $LOG_TEMP
echo "" >> $LOG_TEMP

# Create a pool
expect_normal_exit $PMEMPOOL$EXESUFFIX create --layout=$LAYOUT `
	obj $POOLSET_IN >> $LOG_TEMP

# Transform poolset
$FLAGS=0
expect_normal_exit $Env:EXE_DIR\libpmempool_transform$EXESUFFIX $POOLSET_IN $POOLSET_OUT `
	$FLAGS >> $LOG_TEMP

# Check metadata by pmempool info
dump_pool_info $POOLSET_OUT >> $LOG_TEMP

rm $LOG -Force -ea si
mv $LOG_TEMP $LOG
check

pass
