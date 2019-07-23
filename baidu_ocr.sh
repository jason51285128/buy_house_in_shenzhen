#!/bin/bash
help()
{
    cat <<  HERE
    usage: ./baidu_ocr.sh -f file -l level -a AK -s SK -b dir.file
    -f: specify picture directory or file for query;
    -l: api level, 0, general_basic, 1, accurate_basic;
    -a: AK;
    -s: SK;
    -b: break point
HERE
}

level=0
while getopts "f:l:a:s:hb:" arg
do
    case $arg in
    f)
    targetDir=$OPTARG
    ;;
    l)
    level=$OPTARG
    ;;
    a)
    ak=$OPTARG
    ;;
    s)
    sk=$OPTARG
    ;;
    b)
    break_dir=`echo $OPTARG |  cut -d "." -f1`
    break_file=`echo $OPTARG |  cut -d "." -f2-`
    break_mode="true"
    ;;
    h)
    help
    exit 0
    ;;
    ?)
    help
    exit 1
    ;;
    esac
done

if [ -f "$targetDir" ]
then
    if [ "$break_mode" = "true" ]; then
        echo "can't continue last break point in single mode!"
        exit 1
    fi
    echo "single mode, $targetDir"
elif [ -d "$targetDir" ] 
then
    echo "batch mode, $targetDir"
    if [ "$break_mode" = "true" ]; then
        if [[ -z "$break_dir" || -z "$break_file" ]]; then
        echo "continue last break point, break point invalid!"
        help
        exit 1
        fi        
        echo "continue last break point: $break_dir $break_file"
    fi 
else
    echo "must specify file path use -f !"
    help
    exit 1
fi 

if [[ -z "$ak" || -z "$sk" ]]
then
    echo "invalid AK or SK!"
    help
    exit 1
else
    token=`curl --silent "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=${ak}&client_secret=$sk" | jq .access_token`
    if [ $token = "null" ]
    then
        echo "get access token failed!"
        echo "AK=$ak"
        echo "SK=$sk"
        exit 1
    fi
fi
echo "token=$token"

option="--silent"
head="--header Content-Type:application/x-www-form-urlencoded"
method="-X POST"
data="--data-urlencode"
filter=".words_result[0].words"
err_filter=".error_code"
err_msg_filter=".error_msg"
limit_reached_code="17"
resp_result=
resp_err=
resp_err_msg=
if [ "$level" = "1" ]
then
echo "accurate_basic"
url="https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic?access_token=$token" 
else
echo "general_basic" 
url="https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token=$token" 
fi

baidu_ocr()
{
v=`base64 $1`
resp=`curl $option $head $method $data "image=$v" $url` 
resp_result=`echo $resp | jq $filter`
resp_err=`echo $resp | jq $err_filter`
resp_err_msg=`echo $resp | jq $err_msg_filter`
}

if [ -f "$targetDir" ]
then
    baidu_ocr $targetDir

    if [ resp_result != "null" ]
    then
        echo $resp_result
        exit 0
    else
        echo "failed! $resp_err, $resp_err_msg"
        exit 1
    fi
fi


result=`pwd`/${targetDir}_result.log
rm -rf $result
pushd $targetDir
break_point_found="false"
for i in `ls -l | awk '{print $NF}'`
do
    if [[ "$break_mode" = "true" && "$break_point_found" = "false" ]]; then
        if [ "$i" != "$break_dir" ]; then
            continue
        fi
    fi
    if [ -d "$i" ]
    then
        cd "$i"
        for n in `ls -l | awk '{print $NF}'`
        do
            if [[ "$break_mode" = "true" && "$break_point_found" = "false" ]]; then
                if [ "$n" != "$break_file" ]; then
                    continue
                else
                    break_point_found="true"
                fi
            fi 
            if [ -f "$n" ]
            then
                echo "query $n..."
                while [ "1" = "1" ]
                do
                    baidu_ocr $n
                    if [ "$resp_err" = "null" ]
                    then
                        echo "$targetDir/$i/$n    $resp_result"  >> $result
                        if [ "$resp_result" != "null" ]
                        then
                            mv $n  `echo "$n" | sed "s/jpg_word/jpg_word$resp_result/"`
                        fi
                        sleep 1
                        break
                    fi
                    if [ "$resp_err" = "$limit_reached_code" ]
                    then
                        echo  "$resp_err_msg, query $n retry..."
                        sleep 1800
                        continue
                    fi
                    echo  "$resp_err, $resp_err_msg, skip $n ..."
                    break 
                done
            fi
        done
        cd ..
    fi
done
popd

echo "finish!"
exit 0