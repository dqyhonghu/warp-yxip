#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN='\033[0m'

red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}

# 选择客户端 CPU 架构
archAffix(){
    case "$(uname -m)" in
        i386 | i686 ) echo '386' ;;
        x86_64 | amd64 ) echo 'amd64' ;;
        armv8 | arm64 | aarch64 ) echo 'arm64' ;;
        s390x ) echo 's390x' ;;
        * ) red "不支持的CPU架构!" && exit 1 ;;
    esac
}

endpointyx(){
    # 取消 Linux 自带的线程限制，以便生成优选 Endpoint IP
    ulimit -n 102400
    
    # 启动 WARP Endpoint IP 优选工具
    chmod +x ./warp-linux-$(archAffix) && ./warp-linux-$(archAffix) >/dev/null 2>&1
    
    # 显示前十个优选 Endpoint IP 及使用方法
    green "当前最优 Endpoint IP 结果如下，并已保存至 result.csv中："
    cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | awk -F, '{print "端点 "$1" 丢包率 "$2" 平均延迟 "$3}'
    echo ""
    yellow "使用方法如下："
    yellow "1. 将 WireGuard 节点的默认的 Endpoint IP：engage.cloudflareclient.com:2408 替换成本地网络最优的 Endpoint IP"

    # 删除 WARP Endpoint IP 优选工具及其附属文件
    rm -f ip.txt
}

endpoint4(){
    # 生成优选 WARP IPv4 Endpoint IP 段列表
    temp=()
    IP_MAXNUM=300
    for((n=0; n<=IP_MAXNUM; n++)); do
		case $(($RANDOM % 15)) in
    
			0)
				temp+=($(echo 103.21.$((244 + $RANDOM % 4)).$((1 + $RANDOM % 254))))
                ;;
			1)
				temp+=($(echo 188.114.$((96 + $RANDOM % 16)).$((1 + $RANDOM % 254))))
                ;;
			2)
				temp+=($(echo 162.$((158 + $RANDOM % 2)).$(($RANDOM % 255)).$((1 + $RANDOM % 254))))
                ;;
            3)
				temp+=($(echo 103.22.$((200 + $RANDOM % 4)).$((1 + $RANDOM % 254))))
                ;;
            4)
				temp+=($(echo 103.31.$((4 + $RANDOM % 4)).$((1 + $RANDOM % 254))))
                ;;
            5)
				temp+=($(echo 104.$((16 + $RANDOM % 8)).$(($RANDOM % 255)).$((1 + $RANDOM % 254))))
                ;;
            6)
				temp+=($(echo 104.$((24 + $RANDOM % 4)).$(($RANDOM % 255)).$((1 + $RANDOM % 254))))
                ;;
            7)
				temp+=($(echo 108.162.$((192 + $RANDOM % 64)).$((1 + $RANDOM % 254))))
                ;;
            8)
				temp+=($(echo 131.0.$((72 + $RANDOM % 4)).$((1 + $RANDOM % 254))))
                ;;
            9)
				temp+=($(echo 141.101.$((64 + $RANDOM % 64)).$((1 + $RANDOM % 254))))
                ;;
            10)
				temp+=($(echo 173.245.$((48 + $RANDOM % 16)).$((1 + $RANDOM % 254))))
                ;;
            11)
				temp+=($(echo 190.93.$((240 + $RANDOM % 16)).$((1 + $RANDOM % 254))))
                ;;
            12)
				temp+=($(echo 197.234.$((240 + $RANDOM % 4)).$((1 + $RANDOM % 254))))
                ;;
            13)
				temp+=($(echo 198.41.$((128 + $RANDOM % 128)).$((1 + $RANDOM % 254))))
                ;;
            14)
				temp+=($(echo 172.$((64 + $RANDOM % 8)).$(($RANDOM % 255)).$((1 + $RANDOM % 254))))
                ;;
			*)
				;;
		esac
	done
    # 将生成的 IP 段列表放到 ip.txt 里，待程序优选
    echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u > ip.txt

    # 启动优选程序
    endpointyx
}

endpoint6(){
    # 生成优选 WARP IPv6 Endpoint IP 段列表
    n=0
    iplist=100
    while true; do
        temp[$n]=$(echo [2606:4700:d0::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
        temp[$n]=$(echo [2606:4700:d1::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
        n=$(($n + 1))
        if [ $n -ge $iplist ]; then
            break
        fi
    done
    while true; do
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo [2606:4700:d0::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
            n=$(($n + 1))
        fi
        if [ $(echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u | wc -l) -ge $iplist ]; then
            break
        else
            temp[$n]=$(echo [2606:4700:d1::$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2))):$(printf '%x\n' $(($RANDOM * 2 + $RANDOM % 2)))])
            n=$(($n + 1))
        fi
    done

    # 将生成的 IP 段列表放到 ip.txt 里，待程序优选
    echo ${temp[@]} | sed -e 's/ /\n/g' | sort -u > ip.txt

    # 启动优选程序
    endpointyx
}

menu(){
    clear
    echo "#############################################################"
    echo -e "#               ${RED}WARP Endpoint IP 一键优选脚本${PLAIN}               #"
    echo -e "# ${GREEN}作者${PLAIN}: MisakaNo の 小破站                                  #"
    echo -e "# ${GREEN}博客${PLAIN}: https://blog.misaka.rest                            #"
    echo -e "# ${GREEN}GitHub 项目${PLAIN}: https://github.com/Misaka-blog               #"
    echo -e "# ${GREEN}GitLab 项目${PLAIN}: https://gitlab.com/Misaka-blog               #"
    echo -e "# ${GREEN}Telegram 频道${PLAIN}: https://t.me/misakanocchannel              #"
    echo -e "# ${GREEN}Telegram 群组${PLAIN}: https://t.me/misakanoc                     #"
    echo -e "# ${GREEN}YouTube 频道${PLAIN}: https://www.youtube.com/@misaka-blog        #"
    echo "#############################################################"
    echo ""
    echo -e " ${GREEN}1.${PLAIN} WARP IPv4 Endpoint IP 优选 ${YELLOW}(默认)${PLAIN}"
    echo -e " ${GREEN}2.${PLAIN} WARP IPv6 Endpoint IP 优选"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 退出脚本"
    echo ""
    read -rp "请输入选项 [0-2]: " menuInput
    case $menuInput in
        2 ) endpoint6 ;;
        0 ) exit 1 ;;
        * ) endpoint4 ;;
    esac
}

menu