#!/usr/bin/env bash
cur_dir=`pwd`
version='1.0.0-'$(date "+%Y%m%d.%H%M")
sed -i '' "s/VERSION=.*/VERSION=${version}/g" ${cur_dir}/justicecenter/gradle.properties
./gradlew build justice:bintrayUpload -PbintrayUser=cosmossaas@gmail.com -PbintrayKey=fb7469a974c53aa31ed28bc25a0c26b415657e4f -PdryRun=false
echo ${version}'上传成功'
