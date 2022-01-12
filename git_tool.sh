#!/bin/bash
function pullMaster() {
    git stash
    git checkout master
    git pull origin master
}

function gitBranch(){
	  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function help() {
  echo "============ git 辅助工具 ==============="
  echo "命令："
  echo "h    eg:gg h                查看帮助项"
  echo "d    eg:gg d                将当前分支自动合并到仓库的deploy-test-branch"
  echo "cm   eg:gg cm               切换当前仓库到master分支"
  echo "nb   eg:gg nb [branch name] 新建分支"
  echo "msg  eg:gg msg [commit msg] 将当前分支提交到远程分支"
  echo "m    eg:gg m                当前是git仓库，跳到上一层。当前不是git仓库，会将当前目录下所有git项目切到master并拉最新代码"
  echo "mb   eg:gg mb [A] [B]       合并A分支到B"
}

function pushDeploy() {
    if [[  ! -d '.git' ]];then
      echo -e  "\033[31m[当前不是git仓库]\033[0m 退出"
      exit
    fi
    if [[ `gitBranch` == "deploy-test-branch" ]];then
      echo -e  "\033[31m[当前在deploy分支]\033[0m 退出"
      exit
    fi
    echo -e  "\033[31m[当前分支]\033[0m $1"
    color=$[RANDOM%7 + 31]
    echo -e  "\033[${color}m[提交当前分支]\033[0m 开始"
    branch=$1
    git commit -m"更新分支逻辑" -a
    git push origin $branch
    echo -e  "\033[${color}m[提交当前分支]\033[0m 结束"
    color=$[RANDOM%7 + 31]
    echo
    echo -e  "\033[${color}m[合并deploy]\033[0m 开始"
    git checkout deploy-test-branch
    git pull
    git pull origin $branch
    git push origin deploy-test-branch
    git checkout $branch
    echo -e  "\033[${color}m[合并deploy]\033[0m 结束"
}

function freshMaster() {
  if [[  -d '.git' ]];then
      cd ../
      pwd
    fi
    # shellcheck disable=SC2045
    for name in `ls`; do
      if [ -d $name ];then
        cd $name || echo "$name 不存在"
        if [[  -d '.git'  ]];then
           color=$[RANDOM%7 + 31]
           echo -e  "\033[${color}m[$name]\033[0m 开始处理"
           pullMaster
           echo -e  "\033[${color}m[$name]\033[0m 处理完成"
        else
          echo -e  "\033[31m[$name]\033[0m 不是git仓库"
        fi
        echo
        sleep 1
        cd ../
      fi
    done
}

function mergeBranch() {
  if [[  ! -d '.git' ]];then
        echo -e  "\033[31m[当前不是git仓库]\033[0m 退出"
        exit
      fi
      # shellcheck disable=SC2053
      if [[ `gitBranch` == $2 ]];then
        echo -e  "\033[31m[当前是${2}分支]\033[0m 开始合并 ${1}"
        git pull origin $1
        git push origin $2
        echo -e  "\033[31m[当前是${2}分支]\033[0m 合并结束"
        exit
      fi
      echo -e  "\033[31m[当前分支]\033[0m $1"
      color=$[RANDOM%7 + 31]
      echo -e  "\033[${color}m[提交当前分支]\033[0m 开始"
      branch=$1
      git commit -m"更新分支逻辑" -a
      git push origin $branch
      echo -e  "\033[${color}m[提交当前分支]\033[0m 结束"
      color=$[RANDOM%7 + 31]
      echo
      echo -e  "\033[${color}m[合并到${2}]\033[0m 开始"
      git checkout $2
      git pull
      git pull origin $branch
      git push origin $2
      git checkout $branch
      echo -e  "\033[${color}m[合并到${2}]\033[0m 结束"
}

if [[ $1 == "d" ]]; then
  branchName=$2
  if [[ $branchName == "" ]]; then
    branchName=`gitBranch`
  fi
  pushDeploy $branchName
  exit
fi

if  [[ $1 == 'h' || $1 == 'help' || $1 == '-h' || $1 == '-help'  ]];then
  help
  exit
fi

if  [[ $1 == 'cm' ]];then
  git checkout master
  exit
fi

if [[ $1 == 'nb' ]];then
  if [[ $2 == '' ]];then 
     echo "请输入分支名字";
     exit 
  fi
  git checkout -b $2
  exit
fi

if [[ $1 == 'msg' ]];then
  git commit -m"$2" -a 
  # shellcheck disable=SC2046
  git push origin `gitBranch`
  exit
fi

if  [[ $1 == "m" ]];then
  freshMaster
  exit
fi

if [[ $1 == 'mb' ]];then
  if [[ $2 == "" ]];then
    echo "请输出分支: gg mb [from branch]"
    exit
  fi
  # shellcheck disable=SC2046
  tagetBranch=$3
  if [[ $tagetBranch == "" ]];then
    tagetBranch=`gitBranch`
  fi
  mergeBranch $2 $tagetBranch
  exit
fi

help
