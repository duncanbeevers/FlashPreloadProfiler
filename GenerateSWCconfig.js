var fso = new ActiveXObject( "Scripting.FileSystemObject" );
var shell = WScript.CreateObject("WScript.Shell");
var outFile = fso.createTextFile( "obj/build_swc.xml", true );
 
var fileToCopy = new Array();
var idx = 0;
 
 
// The folder may need to be changed depending on the lib src folder
var src = fso.getFolder( "src" );

outFile.writeLine("<flex-config>");
outFile.writeLine("\t<benchmark>true</benchmark>");
outFile.writeLine("\t<compiler>");
outFile.writeLine("\t\t<external-library-path>");
outFile.writeLine("\t\t\t<path-element>${flexlib}\\libs\\player\\10.1\\playerglobal.swc</path-element>");
outFile.writeLine("\t\t</external-library-path>");
outFile.writeLine("\t\t<source-path>");
outFile.writeLine("\t\t\t<path-element>../src</path-element>");
outFile.writeLine("\t\t</source-path>");
outFile.writeLine("\t</compiler>");
outFile.writeLine("\t<include-classes>");

listFolder( src, outFile, "" );
 

outFile.writeLine("\t</include-classes>");
outFile.writeLine("\t<metadata>");
outFile.writeLine("\t\t<creator>jpauclair</creator>");
outFile.writeLine("\t\t<description>http://jpauclair.net</description>");
outFile.writeLine("\t\t<language>EN</language>");
outFile.writeLine("\t\t<title>FlashPreloadProfiler</title>");
outFile.writeLine("\t</metadata>");
outFile.writeLine("\t<output>..\\bin\\FlashPreloadProfiler.swc</output>");
outFile.writeLine("</flex-config>");


outFile.close();


function listFolder( source, target, package ) 
{
    for( var items = new Enumerator( source.SubFolders ); !items.atEnd(); items.moveNext() ) 
    {
        var currentFolder = items.item();
        listFolder( currentFolder, target, package + currentFolder.name + "." );
    }
    
    for( var files = new Enumerator( source.files ); !files.atEnd(); files.moveNext() ) 
    {
        var currentFile = files.item();
        if( String( currentFile.name ).match( "\.as$" ) ) 
        {
            var component = String( currentFile.name ).replace( "\.as", "" );
            target.writeLine( "\t\t<class>" + package + component + "</class>" );
        }
    }   
} 









