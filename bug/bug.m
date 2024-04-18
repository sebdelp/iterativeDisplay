Let us consider a toolbox where the folders are this way :
\bugdemo
\bugdemo\doc
\bugdemo\code
\bugdemo\code\@myClass1
\bugdemo\code\@myClass2

So the code folder is a place holder for the 2 classes to be distributed.
Note that the "code" folder does not contains any file, only the class folders.


Expected behavior : the toolbox should be packaged
Actual behavior:  error when packaging the toolbox

Reason : cumbersome and erronous way to check if folders in the toolbox path are empty
(seriously, who did write such a code?)


When using   matlab.addons.toolbox.ToolboxOptions, if we try to package this toolbox, the option creations fails because the code folder is empty.
In 2023a, this is due to the ToolboxOptions.m files with the following trace:
+ line 620:                 obj.mustExistInPackageListAsParentFolder(sortedFiles(i));
+ line 760 :  mustExistInPackageListAsParentFolder
+ line 766  if ~obj.folderContainsFileInPackageList(folderToCheck)
+ line 788             containsFile = any(strcmpHandle(fileparts(obj.ToolboxFiles),folderToCheck));

From this 788 line, it is clear that fileparts(obj.ToolboxFiles) should be replaced by a function that also returns the parent folders of any folder "@class".

A short term solution is to add a content.m file in the \bugdemo\code therefore making it non-empty.
A better way would be to fixe line 788 by replacing the empty-folder analysis

I did not check if this bugs persists in other version.
