KLDownloadManage
================
support M3U8 and Multiple File download.
==========


Project Restructuring!! - 2017-12-01
...
--------------------
!!Depercated!! - 2017-11-30
--------------------
<del>struct & Frame
--------
    |
    |- KLPublic // 公用类
    |
	|- DownloadManage // Library
	|          |
    |          |
	|          |- KLModelBase // model 的基类  — 使用此下载类库 需自定义继承自此类的model
	|          |
	|          |- KLDownloadManage // 入口
	|          |
	|          ……
	|
	|- KLDownloadManage // DEMO
	|
	……

Version
------------------
###1.00
使用ASINetwrok来替代网络解决方案～  
可自定义下载路径～  
可代理展示下载进度～  
可下载m3u8～（非live模式）  
###1.03
修正在MRC环境下的内存问题
重构了Model里的变量名预防冲突
</del>
