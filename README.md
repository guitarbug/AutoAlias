# AutoAlias
为TypeAndRun(TAR)批量添加别名(Alias)  
(posted by guitarbug @ 2006.8.14)  

[简介]  
1,TypeAndRun  
借用一下LeoDou@CCF的简介.  
引用:  
>TypeAndRun 是一个使用命令行方式快速打开程序、文件、网址、邮件、文件夹等等的工具。  
>除了可以方便的为自己的常用程序建立别名，TypeAndRun 也内置了大量“系统别名”，用自  
>定义的快捷键调出命令行后，输入别名即可可以执行相应操作。而且TypeAndRun 可以为已经  
>建立的别名自动补全，无需记住全部名称。也不用像一些快捷键工具一样要记住那么多快捷键  
>。很方便哦。
2,AutoAlias
由于TAR的别名需要手动建立,相信如果大家有收集很多小软件的话,一定觉得很麻烦,试过输入输到手酸吗
AutoAlias能在指定的目录下搜索符合指定扩展名的文件,并自动建立与config.ini和history.ini格式相同的文本,方便为TAR批量添加别名

[使用方法]
1,首次使用,AutoAlias会自动搜索当前用户和所有用户的开始菜单和桌面的扩展名为.exe和.lnk的文件,并建立以下3个文件
代码:

AutoAlias.ini:配置文件
AutoAlias_Config.txt:与config.ini相同格式的文本
AutoAlias_History.txt:与history.ini相同格式的文本

2,将AutoAlias_Config.txt里面的内容copy到TAR目录下的config.ini文件末尾
将AutoAlias_history.txt里面的内容copy到TAR目录下的history.ini文件末尾
然后重新载入config.ini文件即可

3,自定义搜索
编辑配置文件AutoAlias.ini,格式是:
代码:

[SearchFolder]
1=F:\Documents and Settings\All Users\Start Menu
2=F:\Documents and Settings\Administrator\Start Menu
3=F:\Documents and Settings\All Users\Desktop
4=F:\Documents and Settings\Administrator\Desktop
[FileExtension]
ext=*.exe *.lnk

在SearchFolder字段添加/修改搜索的目录的路径
在FileExtension字段修改搜索文件的扩展名,多个扩展名用空格分割.

4,注意
如果搜索的目录文件比较多的话,请等待一会,程序结束后,会弹出确认的对话框,并自动打开搜索结果AutoAlias_Config.txt和AutoAlias_History.txt 
