<?php
date_default_timezone_set('PRC');
/**
 * @author 韩志普 <han.zhipu@immomo.com>
 * @date   2022/3/17 2:36 下午
 * @desc   自动创建文件
 */
class Automanager {

    /**
     * @var string base path
     */
    private $basePath;

    /**
     * @var string 类名
     */
    private $className = "";

    /**
     * @var string 模块名
     */
    private $moduleName = "";

    /**
     * @var array 模块下的目录
     */
    private $path = [];

    /**
     * @var string 模块文件目录
     */
    private $module = "";

    /**
     * @var string 创建目标文件的路径
     */
    private $filePath = "";

    /**
     * @var string 目标文件文件名
     */
    private $fileName = "";

    /**
     * @var string ctx 别名
     */
    private $classLastName = "";

    public function __construct($base) {
        $this->basePath = $base;
    }

    public function run() {
        $this->createBaseFile();
    }

    /**
     * 创建base文件
     */
    private function createBaseFile() {
        $this->readName();
        $this->readDesc();

        $content = file_get_contents(__DIR__ . '/manager.tpl');
        $content = str_replace(['{date}', '{className}', '{desc}'], [
            date('Y-m-d H:i:s'),
            $this->className,
            $this->desc
        ], $content);

        //创建文件
        if (!is_file($this->fileName)) {
            file_put_contents($this->fileName, $content);
        }

        //配置ctx
        $ctxFile = $this->module . '/ctx.php';

        //别名
        array_shift($this->path);
        array_push($this->path, $this->classLastName);
        $classCtxName = implode("_", $this->path);

        //追加别名
        $preg         = "/\*\/[\n \s]+class/";
        $toReplace    = "* @property " . $this->className . " \$" . strtolower($classCtxName) . "\n */ \nclass";
        $fileContent  = file_get_contents($ctxFile);
        $content      = preg_replace($preg, $toReplace, $fileContent);
        file_put_contents($ctxFile, $content);

        if (is_file($this->fileName)) {
            echo "操作成功 ~" . PHP_EOL;
        } else {
            echo "操作失败 ~" . PHP_EOL;
        }
    }

    private function initModule() {
        if (!is_dir($this->module)) {
            fwrite(STDOUT, "模块不存在， 是否创建(y 创建 n 取消)：");
            $read = strtolower(trim(fgets(STDIN)));
            if ($read == 'y') {
                $toMake = $this->module;
                @mkdir($toMake);
                echo "成功创建目录：" . $toMake . PHP_EOL;
                $ctx = $this->module . "/" . "ctx.php";
                $this->mkCtx($ctx);
                echo "成功创建文件:" . $ctx . PHP_EOL;
            } else {
                echo "退出程序" . PHP_EOL;
                exit;
            }
        }

        $next   = 1;
        $toMake = $this->module;
        while (isset($this->path[$next])) {
            $toMake .= "/" . $this->path[$next];
            if (!is_dir($toMake)) {
                @mkdir($toMake);
                echo "成功创建目录：" . $toMake . PHP_EOL;
            }
            $next++;
        }
    }

    private function parseName() {
        $parsed = explode('_', $this->className);
        if (count($parsed) < 4) {
            fwrite(STDOUT, "类名不符合规范");
            return false;
        }

        //创建目录
        $this->module     = $this->basePath . '/' . strtolower($parsed['1']);
        $this->moduleName = $parsed[1];
        $this->path       = array_map('strtolower', array_slice($parsed, 1, -1));
        $this->initModule();

        $this->filePath      = $this->basePath . "/" . implode('/', $this->path);
        $this->classLastName = strtolower(array_pop($parsed));
        $this->fileName      = $this->filePath . "/" . $this->classLastName . '.php';
        return true;
    }

    private function readName() {
        while (!$this->className) {
            fwrite(STDOUT, "请输入类名：");
            $name = trim(fgets(STDIN));
            if (empty($name)) {
                fwrite(STDOUT, "输入为空，请重试");
            } else {
                $this->className = $name;
                $res             = $this->parseName();
                if ($res) {
                    break;
                }
            }
        }
    }

    private function readDesc() {
        fwrite(STDOUT, "请输入类描述：");
        $desc = strtolower(trim(fgets(STDIN)));
        if (empty($desc)) {
            $desc = $this->fileName;
        }
        $this->desc = $desc;
    }

    private function mkCtx($fileName) {
        $content = file_get_contents(__DIR__ . '/ctx.tpl');
        $content = str_replace(['{date}', '{module}'], [
            date('Y-m-d H:i:s'),
            ucfirst($this->moduleName)
        ], $content);
        file_put_contents($fileName, $content);
    }
}
(new Automanager($argv[1]))->run();