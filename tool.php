<?php
/**
 * @author 韩志普 <han.zhipu@immomo.com>
 * @date   2022/7/4 2:14 下午
 * @desc   工具
 */
class Tool {
    /**
     * 读交互变量
     *
     * @param      $name
     * @param null $callBack
     * @return string
     */
    public static function readVal($name, $callBack = null) {
        $tmp = "";
        while (!$tmp) {
            fwrite(STDOUT, sprintf("%s：", $name));
            $value = trim(fgets(STDIN));
            if (empty($value)) {
                fwrite(STDOUT, "输入为空，请重试");
            } else {
                if (is_callable($callBack)) {
                    $err = $callBack($value);
                    if ($err) {
                        fwrite(STDOUT, '输入有误：' . $err);
                        continue;
                    }
                }
                $tmp = $value;
                break;
            }
        }
        return $tmp;
    }
}

//Tool::readVal('姓名', function($in) {
//    if (strlen($in) < 5) {
//        return '姓名长度不能小于5';
//    }
//    return false;
//});