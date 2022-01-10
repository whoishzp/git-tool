#!/bin/bash
function pullMaster() {
    git stash
    git checkout master
    git pull origin master
}

gitBranch(){
	  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
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
    echo -e  "\033[${color}m[合并deplay]\033[0m 开始"
    git checkout deploy-test-branch
    git pull
    git pull origin $branch
    git push origin deploy-test-branch
    git checkout $branch
    echo -e  "\033[${color}m[合并deplay]\033[0m 结束"
}

if [[ $1 == "md" ]]; then
  branchName=$2
  if [[ $branchName == "" ]]; then
    branchName=`gitBranch`
  fi
  pushDeploy $branchName
elif  [[ $1 == "pm" ]];then
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
else
   branchName=$2
    if [[ $branchName == "" ]]; then
      branchName=`gitBranch`
    fi
    pushDeploy $branchName
fi