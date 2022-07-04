<?php

date_default_timezone_set('PRC');

include_once __DIR__ ."/tool.php";

class Api {
    private $controllerPath = "/Users/momo/Documents/project/pj-web/web/php/newapp/controllers/api";
    private $routePath = "/Users/momo/Documents/project/pj-web/web/php/newapp/routes";
    private $routeName = "";
    private $methods = [];

    public function run() {
        $msg = "==========================================================" . PHP_EOL;
        $msg .= "路由说明：".PHP_EOL;
        $msg .= "路由：ModuelName}/{controllerName}}/{methodName1#methodName2}" . PHP_EOL;
        $msg .= "ModuleName：对应模块，用于寻找controller 和 routes 文件" . PHP_EOL;
        $msg .= "ControllerName：控制器前缀，如：Index 代表：IndexController" . PHP_EOL;
        $msg .= "methodNameX： 控制器方法， 一次可以创建多个方法，用#分割" . PHP_EOL;
        $msg .= "==========================================================" . PHP_EOL;
        $msg .= '请输入路由规则';
        $routeName = Tool::readVal($msg, function($input) {
            $res = explode("/", $input);
            if (count($res) != 3) {
                return "请输入有效路由";
            }

            return false;
        });
        if (empty($routeName)) {
            echo "请输入有效路由名称" . PHP_EOL;
        }

        $this->routeName = $routeName;

        $this->parseRoute();
    }

    /**
     * 检查模块是否存在
     */
    private function parseRoute() {
        $explodeInfo = explode('/', $this->routeName);
        list($module, $controller, $method) = $explodeInfo;

        $this->methods = explode('#', $method);

        $msg = "路由解析：" . PHP_EOL;
        $msg .= "模块：" . $module . PHP_EOL;
        $msg .= '控制器：' . $controller . PHP_EOL;
        $msg .= '方法：' . $method . PHP_EOL;
        echo $msg . PHP_EOL;

        $this->buildCode($module, $controller);
    }

    private function buildCode($module, $controller) {
        $controllerDir = $this->controllerPath . "/".$module;
        $routeFile = $this->routePath . "/". strtolower($module) . ".php";
        $controllerFile = $controllerDir . "/" . $controller . "Controller.php";
        if (!is_dir($controllerDir)) {
            echo "目录不存在，创建目录：" . $controllerDir . PHP_EOL;
            @mkdir($controllerDir);
        }
        if (!is_file($controllerFile)) {
            echo "文件不存在，创建文件：" . $controllerFile . PHP_EOL;
            $this->buildControllerFile($controllerFile, $module, $controller);
        }

        echo "添加方法..." . PHP_EOL;
        foreach ($this->methods as $method) {
             $this->buildControllerCode($controllerFile, $method);
        }

        //路由
        if (!is_file($routeFile)) {
            echo "文件不存在，创建文件：" . $routeFile . PHP_EOL;
            $this->buildRouteFile($routeFile);
        }

        echo "添加路由.." . PHP_EOL;
        foreach ($this->methods as $method) {
            $this->buildRouteCode($routeFile, $module, $controller, $method);
        }
    }

    private function buildRouteFile($routeFile) {
        $content = file_get_contents(__DIR__ . '/tpls/route.tpl');
        $content = str_replace(['{date}'], [
            date('Y-m-d H:i:s'),
        ], $content);
        file_put_contents($routeFile, $content);
        echo "创建路由文件成功" . PHP_EOL;
    }

    private function buildControllerFile($file, $module, $controller) {
        if (is_file($file)) {
            echo "文件存在" . PHP_EOL;
            return;
        }
        $content = file_get_contents(__DIR__ . '/tpls/controller.tpl');
        $content = str_replace(['{date}', '{ModuleName}', '{ControllerName}'], [
            date('Y-m-d H:i:s'),
            $module, $controller
        ], $content);
        file_put_contents($file, $content);
        echo "创建控制器成功" . PHP_EOL;
    }

    private function buildControllerCode($file, $method) {
        $functionInfo = file_get_contents(__DIR__ . '/tpls/method.tpl');
        $content = str_replace(['{methodName}'], [
            $method
        ], $functionInfo);

        $fileInfo = file_get_contents($file);
        if (strpos($fileInfo, "public function " . $method) === false) {
            $fileInfo = str_replace("extends BaseController {", "extends BaseController {\n\n" . $content, $fileInfo);
            file_put_contents($file, $fileInfo);
        }

        echo "创建方法成功:" . $method . PHP_EOL;
    }

    private function buildRouteCode($routeFile, $module, $controller, $method) {
        $useContent = "use App\\Controllers\\Api\\" . $module . "\\" . $controller . "Controller;" . PHP_EOL;
        $routeContent = file_get_contents($routeFile);
        if (strpos($routeContent, $useContent) === false) {
            file_put_contents($routeFile, $useContent, FILE_APPEND);
        }

        if ($controller === 'Index') {
            $route = "/$module/$method";
        } else {
            $route = "/$module/$controller/$method";
        }
        $route = strtolower($route);

        echo "添加路由：/api" . $route . PHP_EOL;

        $routeInfo = '$router->post("'. $route . '", '.$controller.'Controller::class . "@'. $method .'");' . PHP_EOL;
        $routeContent = file_get_contents($routeFile);
        if (strpos($routeContent, $routeInfo) === false) {
            file_put_contents($routeFile, $routeInfo, FILE_APPEND);
        }
    }
}
(new Api())->run();