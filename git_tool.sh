#!/bin/bash
function pullMaster() {
    git pull origin master
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
  echo "msg  eg:gg msg [commit msg] 提交当前分支并提交到远程分支"
  echo "m    eg:gg m                当前是git仓库，跳到上一层。当前不是git仓库，会将当前目录下所有git项目切到master并拉最新代码"
  echo "mb   eg:gg mb [A] [B]       合并A分支到B"
  echo "mt   eg:gg mt [B]           合并当前分支到分支到B"
  echo "pm   eg:gg pm               pull origin master"
  echo "c    eg:gg c [branch]       git checkout branch"
  echo "mf   eg:gg mf [className]   自动创建类,并追加ctx"
  echo "api  eg:gg api              自动创建控制器api"
  echo "now  eg:gg now              返回当前所有目录所在分支"
  echo "ac  eg:gg ac A Create       将当前目录下所有git包切到指定分支, Create  = 1 时新建分支"
}

# 当前目录名
function nowDirNameName() {
   pwd | awk -F "/" '{print $NF}'
}

# 切换到deploy-test-branch
function pushDeploy() {
    if [[  ! -d '.git' ]];then
      echo -e  "\033[35m[当前不是git仓库]\033[0m"
      exit
    fi

    localDirName=`nowDirNameName`
    if [[ $localDirName == 'frontend' ]];then
      deployBranch='develop'
    else
      deployBranch='deploy-test-branch'
    fi

    if [[ `gitBranch` == "deploy-test-branch" || `gitBranch` == 'develop' ]];then
      echo -e  "\033[35m[当前在deploy分支]\033[0m"
      exit
    fi
    if [[ `gitBranch` != $1 ]];then
          echo -e "\033[36m【 当前分支`gitBranch` 】\033[0m"
          echo -e "\033[36m【 git commit -m提交改动 -a 】\033[0m"
          branch=$1
          git commit -m"更新分支逻辑" -a  >> /dev/null 2>&1
          echo -e "\033[36m【 git push origin `gitBranch`  】\033[0m"
          # shellcheck disable=SC2046
          git push origin `gitBranch` >> /dev/null 2>&1
          git checkout $1 >> /dev/null 2>&1
    fi

    echo -e "\033[35m【 开始合并 】\033[0m"
    echo -e "\033[36m【 git commit -m提交改动 -a 】\033[0m"
    branch=$1
    git commit -m"更新分支逻辑" -a  >> /dev/null 2>&1
    echo -e "\033[36m【 git push origin $branch  】\033[0m"
    git push origin $branch
    echo
    echo -e "\033[36m【 避免出错：sleep 2 】\033[0m"
    sleep 2
    echo
    echo -e "\033[36m【  git checkout $deployBranch  】\033[0m"
    git checkout $deployBranch  >> /dev/null 2>&1
    echo -e "\033[36m【 git pull 】\033[0m"
    git pull
    echo -e "\033[36m【 git pull origin $branch  】\033[0m"
    `gitBranch` != 'master' && git pull origin $branch
    echo -e "\033[36m【 git push origin $deployBranch 】\033[0m"
    git push origin $deployBranch  >> /dev/null 2>&1
    echo -e "\033[36m【 git checkout $branch  】\033[0m"
    git checkout $branch  >> /dev/null 2>&1
    echo -e "\033[32m【 合并成功 】\033[0m"
}

# 切换所有git到master
function freshMaster() {
  if [[  -d '.git' ]];then
      cd ../
      pwd
    fi
    # shellcheck disable=SC2045
    for name in `ls`; do
      if [[ $name == 'git-tool' || $name == 'www-frontend' || $name == 'aide' || $name == 'package' || $name == 'report' || $name == 'test-gee' || $name == 'test-cut' ]]; then
        continue
      fi
      if [ -d $name ];then
        cd $name || echo "$name 不存在"
        if [[  -d '.git'  ]];then
           color=$[RANDOM%7 + 31]
           echo -e  "\033[${color}m[$name]\033[0m 开始处理"
           pullMaster
           echo -e  "\033[${color}m[$name]\033[0m 处理完成"
        else
          echo -e  "\033[35m[$name]\033[0m 不是git仓库"
        fi
        echo
        
        cd ../
      fi
    done
}

# 切换所有git到指定分支
function allChangeBranch() {
    newBranch=$2
    echo -e "\033[35m【 开始切换 】\033[0m"
    if [[  -d '.git' ]];then
          cd ../
          echo -e "\033[35m【 当前目录：`pwd` 】\033[0m"
    fi

    # shellcheck disable=SC2045
    for name in `ls`; do
      if [[ $name == 'git-tool' || $name == 'www-frontend' || $name == 'aide' || $name == 'package' || $name == 'report' || $name == 'test-gee' || $name == 'test-cut' ]]; then
        continue
      fi

      if [ -d $name ];then
        cd $name || echo -e "\033[36m【 目录不存在：$name 】\033[0m"
        if [[  -d '.git'  ]];then
          echo -e "\033[36m【 处理目录：$name 】\033[0m"
          finishNowBranch
          function switchBranch() {
             echo -e "\033[35m【 切到分支：$1 】\033[0m"
             echo -e "\033[36m【 执行：git pull origin $1 && git pull origin master && git push origin $1 】\033[0m"
             git checkout $1
             `gitBranch` != 'master' && git pull origin $1
             git pull origin master
             git push origin $1  >> /dev/null 2>&1
          }
          # 在当前分支
          if [[ `gitBranch` == $1 ]];then
               switchBranch $1
               echo -e "\033[32m【 目录处理成功：$name 】\033[0m"
               cd ../
               continue
          fi
          # 分支存在
          color=$[RANDOM%7 + 31]
          hashBranch=`git branch | grep $1 | wc | awk '{print $1}'`
          if [[ $hashBranch == 1 ]];then
            switchBranch $1
            echo -e "\033[32m【 目录处理成功：$name 】\033[0m"
            cd ../
            continue
          # 分支不存在，但需要创建
          elif [[ $hashBranch != 1 && $newBranch == 1 ]];then
             echo -e "\033[36m【 分支不存在，新建分支：$1 】\033[0m"
             echo -e "\033[36m【 git checkout master && git pull origin master && git checkout -b $1 && git push origin $1 】\033[0m"
             git checkout master   >> /dev/null 2>&1
             git pull origin master 
             git checkout -b $1   >> /dev/null 2>&1
             git push origin $1   >> /dev/null 2>&1
             echo -e "\033[32m【 目录处理成功：$name 】\033[0m"
             cd ../
             continue
          else
             echo -e "\033[36m【 分支不存在，不新建分支 】\033[0m"
             echo -e "\033[32m【 目录处理成功：$name 】\033[0m"
             cd ../
             continue
          fi
        else
          echo -e "\033[32m【 不是git仓库：$name 】\033[0m"
          cd ../
          continue
        fi
        echo -e "\033[32m【 不是目录：$name 】\033[0m"
        cd ../
      fi
    done
}

# 提交当前分支
function finishNowBranch() {
  localBranch=`gitBranch`
  if [[ $localBranch != 'master' ]];then
         echo -e "\033[35m【 当前分支：$localBranch 】\033[0m"
         echo -e "\033[36m【 git commit -m '提交改动' *  】\033[0m"
         git commit -m "提交改动" *   >> /dev/null 2>&1
         echo -e "\033[36m【 git push origin $localBranch  】\033[0m"
         git push origin $localBranch
    fi
}

# 合并两个分支
function mergeBranch() {
  if [[  ! -d '.git' ]];then
        echo -e  "\033[35m[当前不是git仓库]\033[0m 退出"
        exit
      fi
      # shellcheck disable=SC2053
      if [[ `gitBranch` == $2 ]];then
        echo -e  "\033[35m[当前是${2}分支]开始合并 ${1}\033[0m "
        `gitBranch` != 'master' && git pull origin $1
        git push origin $2
        echo -e  "\033[35m[当前是${2}分支]合并结束\033[0m "
        exit
      fi
      echo -e  "\033[35m[当前分支] $1\033[0m"
      color=$[RANDOM%7 + 31]
      echo -e  "\033[${color}m[提交当前分支]开始\033[0m "
      branch=$1
      if [[ `gitBranch` != $branch ]];then
        echo -e "\033[${color}m[当前分支不对] 当前分支[`gitBranch`],需要合并的来源分支[$branch ]\033[0m"
        exit
      fi
      echo -e "\033[36m【 git commit -m"更新分支逻辑" -a 】\033[0m"
      git commit -m"更新分支逻辑" -a  >> /dev/null 2>&1
      git push origin $branch
      echo -e  "\033[${color}m[提交当前分支] 结束\033[0m"
      color=$[RANDOM%7 + 31]
      echo
      echo -e "\033[36m【 git checkout $2 】\033[0m"
      git checkout $2  >> /dev/null 2>&1
      echo -e "\033[36m【 git pull 】\033[0m"
      git pull
      echo -e "\033[36m【 git pull origin $branch 】\033[0m"
      `gitBranch` != 'master' && git pull origin $branch
      echo -e "\033[36m【 git push origin $2 】\033[0m"
      git push origin $2  >> /dev/null 2>&1
      echo -e "\033[36m【 git checkout $branch 】\033[0m"
      git checkout $branch  >> /dev/null 2>&1
      echo -e  "\033[${color}m[合并到${2}]结束\033[0m "
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

if [[ $1 == 'now' ]];then
        if [[  -d '.git' ]];then
          cd ../
        fi
        # shellcheck disable=SC2045
        for name in `ls`; do
          if [[ $name == 'git-tool' || $name == 'www-frontend' || $name == 'aide' || $name == 'package' || $name == 'report' || $name == 'test-gee' || $name == 'test-cut' ]]; then
            continue
          fi
          if [ -d $name ];then
            cd $name || echo "$name 不存在"
            if [[  -d '.git'  ]];then
              echo -e  "$name\033[35m[`gitBranch`]\033[0m"
              git status
            else
              cd ../
              continue
            fi
            cd ../
          fi
        done
        exit
fi

if  [[ $1 == 'cm' ]];then
  finishNowBranch
  git checkout master
  git pull origin master
  exit
fi

if [[ $1 == 'nb' ]];then
  if [[ $2 == '' ]];then 
     echo "请输入分支名字";
     exit 
  fi
  echo -e "\033[35m【 git checkout -b $2 】\033[0m"
  git checkout -b $2
  exit
fi

if [[ $1 == 'msg' ]];then
  echo -e "\033[35m【 开始提交 】\033[0m"
  echo -e "\033[36m【 git commit -m"$2" -a 】\033[0m"
  git commit -m"$2" -a  >> /dev/null 2>&1
 echo -e "\033[36m【 git pull origin master 】\033[0m"
 git pull origin master
  # shellcheck disable=SC2046
  echo -e "\033[36m【 git push origin `gitBranch` 】\033[0m"
  git push origin `gitBranch`
  echo -e "\033[32m【 提交成功 】\033[0m"
  exit
fi

if  [[ $1 == "m" ]];then
  freshMaster
  exit
fi

if [[ $1 == 'mb' ]];then
  echo -e "\033[35m【 请使用gg mt [target branch] 】\033[0m"
  exit
  if [[ $2 == "" ]];then
    echo "请输入分支: gg mb [from branch]"
    exit
  fi
  # shellcheck disable=SC2046
  tagetBranch=$3
  if [[ $tagetBranch == "" ]];then
    tagetBranch=`gitBranch`
  fi
  git commit -m "合并前先提交" *
  git push origin `gitBranch`
  mergeBranch $2 $tagetBranch
  exit
fi

if [[ $1 == 'mt' ]];then
  if [[ $2 == "" ]];then
    echo "请输入分支: gg mt [Target Branch]"
    exit
  fi
  # shellcheck disable=SC2046
  targetBranch=$2
  localBranch=`gitBranch`
  echo -e "\033[35m【 初始化 】\033[0m"
  git commit -m"提交改动" *  >> /dev/null 2>&1
  git push origin $localBranch
  echo -e "\033[35m【 开始合并 】\033[0m"
  mergeBranch $localBranch $tagetBranch
  exit
fi

if [[ $1 == "pm" ]];then
  git pull origin master
  exit
fi

if [[ $1 == "ac" ]];then
  if [[ $2 == '' ]];then
    echo -e "\033[35m【 请输入分支名 】\033[0m"
  fi
  create=0
  if [[ $3 != '' ]];then
    create=1
  fi
  allChangeBranch $2 $create
  exit
fi

if [[ $1 == 'c' ]]; then
  localBranch=`gitBranch`
  if [[ $2 == "" ]];then
     echo -e "\033[35m【 开始提交 】\033[0m"
     echo -e "\033[36m【 git commit -m 提交改动 * 】\033[0m"
     git commit -m "提交改动" *   >> /dev/null 2>&1
     echo -e "\033[36m【 git pull origin master 】\033[0m"
     git pull origin master 
     if [[ $localBranch != 'master' ]];then
       echo -e "\033[36m【 git push origin $localBranch 】\033[0m"
       git push origin $localBranch
     fi
     echo -e "\033[32m【 提交结束 】\033[0m"
     exit
  fi
  echo -e "\033[35m【 开始 】\033[0m"
  echo -e "\033[35m【 当前分支：$localBranch 】\033[0m"
  finishNowBranch
  echo -e "\033[36m【 git checkout $2 】\033[0m"
  git checkout $2   >> /dev/null 2>&1
  echo -e "\033[36m【 git pull origin $2 】\033[0m"
  `gitBranch` != 'master' && git pull origin $2
  echo -e "\033[36m【 git pull origin master 】\033[0m"
  git pull origin master 
  echo -e "\033[36m【 git push origin $2 】\033[0m"
  git push origin $2   >> /dev/null 2>&1
  echo -e "\033[32m【 切换分支成功 】\033[0m"
  exit
fi

if [[ $1 == 'mf' ]]; then
  originPath=`pwd`
  base=`pwd`"/base"
  if [[  ! -d $base ]]; then
    mkdir $base
  fi

  # shellcheck disable=SC2164
  cd "/Users/momo/Documents/project/pj-web/git-tool"
  php "./automanager.php" $base
  # shellcheck disable=SC2164
  cd $originPath
  git add .
  exit
fi

if [[ $1 == 'api' ]]; then
  originPath=`pwd`
  base=`pwd`"/base"
  if [[  ! -d $base ]]; then
    mkdir $base
  fi

  # shellcheck disable=SC2164
  cd "/Users/momo/Documents/project/pj-web/git-tool"
  php "./api.php" $base
  # shellcheck disable=SC2164
  cd $originPath
  git add .
  exit
fi

help
