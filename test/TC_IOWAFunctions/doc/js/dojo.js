/*
	Copyright (c) 2004-2005, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

/*
	This is a compiled version of Dojo, built for deployment and not for
	development. To get an editable version, please visit:

		http://dojotoolkit.org

	for documentation and information on getting the source.
*/

var dj_global=this;
function dj_undef(_1,_2){
if(!_2){
_2=dj_global;
}
return (typeof _2[_1]=="undefined");
}
if(dj_undef("djConfig")){
var djConfig={};
}
var dojo;
if(dj_undef("dojo")){
dojo={};
}
dojo.version={major:0,minor:2,patch:2,flag:"",revision:Number("$Rev: 2836 $".match(/[0-9]+/)[0]),toString:function(){
with(dojo.version){
return major+"."+minor+"."+patch+flag+" ("+revision+")";
}
}};
dojo.evalObjPath=function(_3,_4){
if(typeof _3!="string"){
return dj_global;
}
if(_3.indexOf(".")==-1){
if((dj_undef(_3,dj_global))&&(_4)){
dj_global[_3]={};
}
return dj_global[_3];
}
var _5=_3.split(/\./);
var _6=dj_global;
for(var i=0;i<_5.length;++i){
if(!_4){
_6=_6[_5[i]];
if((typeof _6=="undefined")||(!_6)){
return _6;
}
}else{
if(dj_undef(_5[i],_6)){
_6[_5[i]]={};
}
_6=_6[_5[i]];
}
}
return _6;
};
dojo.errorToString=function(_8){
return ((!dj_undef("message",_8))?_8.message:(dj_undef("description",_8)?_8:_8.description));
};
dojo.raise=function(_9,_a){
if(_a){
_9=_9+": "+dojo.errorToString(_a);
}
var he=dojo.hostenv;
if((!dj_undef("hostenv",dojo))&&(!dj_undef("println",dojo.hostenv))){
dojo.hostenv.println("FATAL: "+_9);
}
throw Error(_9);
};
dj_throw=dj_rethrow=function(m,e){
dojo.deprecated("dj_throw and dj_rethrow deprecated, use dojo.raise instead");
dojo.raise(m,e);
};
dojo.debug=function(){
if(!djConfig.isDebug){
return;
}
var _e=arguments;
if(dj_undef("println",dojo.hostenv)){
dojo.raise("dojo.debug not available (yet?)");
}
var _f=dj_global["jum"]&&!dj_global["jum"].isBrowser;
var s=[(_f?"":"DEBUG: ")];
for(var i=0;i<_e.length;++i){
if(!false&&_e[i] instanceof Error){
var msg="["+_e[i].name+": "+dojo.errorToString(_e[i])+(_e[i].fileName?", file: "+_e[i].fileName:"")+(_e[i].lineNumber?", line: "+_e[i].lineNumber:"")+"]";
}else{
try{
var msg=String(_e[i]);
}
catch(e){
if(dojo.render.html.ie){
var msg="[ActiveXObject]";
}else{
var msg="[unknown]";
}
}
}
s.push(msg);
}
if(_f){
jum.debug(s.join(" "));
}else{
dojo.hostenv.println(s.join(" "));
}
};
dojo.debugShallow=function(obj){
if(!djConfig.isDebug){
return;
}
dojo.debug("------------------------------------------------------------");
dojo.debug("Object: "+obj);
for(i in obj){
dojo.debug(i+": "+obj[i]);
}
dojo.debug("------------------------------------------------------------");
};
var dj_debug=dojo.debug;
function dj_eval(s){
return dj_global.eval?dj_global.eval(s):eval(s);
}
dj_unimplemented=dojo.unimplemented=function(_15,_16){
var _17="'"+_15+"' not implemented";
if((!dj_undef(_16))&&(_16)){
_17+=" "+_16;
}
dojo.raise(_17);
};
dj_deprecated=dojo.deprecated=function(_18,_19,_1a){
var _1b="DEPRECATED: "+_18;
if(_19){
_1b+=" "+_19;
}
if(_1a){
_1b+=" -- will be removed in version: "+_1a;
}
dojo.debug(_1b);
};
dojo.inherits=function(_1c,_1d){
if(typeof _1d!="function"){
dojo.raise("superclass: "+_1d+" borken");
}
_1c.prototype=new _1d();
_1c.prototype.constructor=_1c;
_1c.superclass=_1d.prototype;
_1c["super"]=_1d.prototype;
};
dj_inherits=function(_1e,_1f){
dojo.deprecated("dj_inherits deprecated, use dojo.inherits instead");
dojo.inherits(_1e,_1f);
};
dojo.render=(function(){
function vscaffold(_20,_21){
var tmp={capable:false,support:{builtin:false,plugin:false},prefixes:_20};
for(var x in _21){
tmp[x]=false;
}
return tmp;
}
return {name:"",ver:dojo.version,os:{win:false,linux:false,osx:false},html:vscaffold(["html"],["ie","opera","khtml","safari","moz"]),svg:vscaffold(["svg"],["corel","adobe","batik"]),vml:vscaffold(["vml"],["ie"]),swf:vscaffold(["Swf","Flash","Mm"],["mm"]),swt:vscaffold(["Swt"],["ibm"])};
})();
dojo.hostenv=(function(){
var _24={isDebug:false,allowQueryConfig:false,baseScriptUri:"",baseRelativePath:"",libraryScriptUri:"",iePreventClobber:false,ieClobberMinimal:true,preventBackButtonFix:true,searchIds:[],parseWidgets:true};
if(typeof djConfig=="undefined"){
djConfig=_24;
}else{
for(var _25 in _24){
if(typeof djConfig[_25]=="undefined"){
djConfig[_25]=_24[_25];
}
}
}
var djc=djConfig;
function _def(obj,_28,def){
return (dj_undef(_28,obj)?def:obj[_28]);
}
return {name_:"(unset)",version_:"(unset)",pkgFileName:"__package__",loading_modules_:{},loaded_modules_:{},addedToLoadingCount:[],removedFromLoadingCount:[],inFlightCount:0,modulePrefixes_:{dojo:{name:"dojo",value:"src"}},setModulePrefix:function(_2a,_2b){
this.modulePrefixes_[_2a]={name:_2a,value:_2b};
},getModulePrefix:function(_2c){
var mp=this.modulePrefixes_;
if((mp[_2c])&&(mp[_2c]["name"])){
return mp[_2c].value;
}
return _2c;
},getTextStack:[],loadUriStack:[],loadedUris:[],post_load_:false,modulesLoadedListeners:[],getName:function(){
return this.name_;
},getVersion:function(){
return this.version_;
},getText:function(uri){
dojo.unimplemented("getText","uri="+uri);
},getLibraryScriptUri:function(){
dojo.unimplemented("getLibraryScriptUri","");
}};
})();
dojo.hostenv.getBaseScriptUri=function(){
if(djConfig.baseScriptUri.length){
return djConfig.baseScriptUri;
}
var uri=new String(djConfig.libraryScriptUri||djConfig.baseRelativePath);
if(!uri){
dojo.raise("Nothing returned by getLibraryScriptUri(): "+uri);
}
var _30=uri.lastIndexOf("/");
djConfig.baseScriptUri=djConfig.baseRelativePath;
return djConfig.baseScriptUri;
};
dojo.hostenv.setBaseScriptUri=function(uri){
djConfig.baseScriptUri=uri;
};
dojo.hostenv.loadPath=function(_32,_33,cb){
if((_32.charAt(0)=="/")||(_32.match(/^\w+:/))){
dojo.raise("relpath '"+_32+"'; must be relative");
}
var uri=this.getBaseScriptUri()+_32;
if(djConfig.cacheBust&&dojo.render.html.capable){
uri+="?"+String(djConfig.cacheBust).replace(/\W+/g,"");
}
try{
return ((!_33)?this.loadUri(uri,cb):this.loadUriAndCheck(uri,_33,cb));
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.hostenv.loadUri=function(uri,cb){
if(this.loadedUris[uri]){
return;
}
var _38=this.getText(uri,null,true);
if(_38==null){
return 0;
}
this.loadedUris[uri]=true;
var _39=dj_eval(_38);
return 1;
};
dojo.hostenv.loadUriAndCheck=function(uri,_3b,cb){
var ok=true;
try{
ok=this.loadUri(uri,cb);
}
catch(e){
dojo.debug("failed loading ",uri," with error: ",e);
}
return ((ok)&&(this.findModule(_3b,false)))?true:false;
};
dojo.loaded=function(){
};
dojo.hostenv.loaded=function(){
this.post_load_=true;
var mll=this.modulesLoadedListeners;
for(var x=0;x<mll.length;x++){
mll[x]();
}
dojo.loaded();
};
dojo.addOnLoad=function(obj,_41){
if(arguments.length==1){
dojo.hostenv.modulesLoadedListeners.push(obj);
}else{
if(arguments.length>1){
dojo.hostenv.modulesLoadedListeners.push(function(){
obj[_41]();
});
}
}
};
dojo.hostenv.modulesLoaded=function(){
if(this.post_load_){
return;
}
if((this.loadUriStack.length==0)&&(this.getTextStack.length==0)){
if(this.inFlightCount>0){
dojo.debug("files still in flight!");
return;
}
if(typeof setTimeout=="object"){
setTimeout("dojo.hostenv.loaded();",0);
}else{
dojo.hostenv.loaded();
}
}
};
dojo.hostenv.moduleLoaded=function(_42){
var _43=dojo.evalObjPath((_42.split(".").slice(0,-1)).join("."));
this.loaded_modules_[(new String(_42)).toLowerCase()]=_43;
};
dojo.hostenv._global_omit_module_check=false;
dojo.hostenv.loadModule=function(_44,_45,_46){
if(!_44){
return;
}
_46=this._global_omit_module_check||_46;
var _47=this.findModule(_44,false);
if(_47){
return _47;
}
if(dj_undef(_44,this.loading_modules_)){
this.addedToLoadingCount.push(_44);
}
this.loading_modules_[_44]=1;
var _48=_44.replace(/\./g,"/")+".js";
var _49=_44.split(".");
var _4a=_44.split(".");
for(var i=_49.length-1;i>0;i--){
var _4c=_49.slice(0,i).join(".");
var _4d=this.getModulePrefix(_4c);
if(_4d!=_4c){
_49.splice(0,i,_4d);
break;
}
}
var _4e=_49[_49.length-1];
if(_4e=="*"){
_44=(_4a.slice(0,-1)).join(".");
while(_49.length){
_49.pop();
_49.push(this.pkgFileName);
_48=_49.join("/")+".js";
if(_48.charAt(0)=="/"){
_48=_48.slice(1);
}
ok=this.loadPath(_48,((!_46)?_44:null));
if(ok){
break;
}
_49.pop();
}
}else{
_48=_49.join("/")+".js";
_44=_4a.join(".");
var ok=this.loadPath(_48,((!_46)?_44:null));
if((!ok)&&(!_45)){
_49.pop();
while(_49.length){
_48=_49.join("/")+".js";
ok=this.loadPath(_48,((!_46)?_44:null));
if(ok){
break;
}
_49.pop();
_48=_49.join("/")+"/"+this.pkgFileName+".js";
if(_48.charAt(0)=="/"){
_48=_48.slice(1);
}
ok=this.loadPath(_48,((!_46)?_44:null));
if(ok){
break;
}
}
}
if((!ok)&&(!_46)){
dojo.raise("Could not load '"+_44+"'; last tried '"+_48+"'");
}
}
if(!_46){
_47=this.findModule(_44,false);
if(!_47){
dojo.raise("symbol '"+_44+"' is not defined after loading '"+_48+"'");
}
}
return _47;
};
dojo.hostenv.startPackage=function(_50){
var _51=_50.split(/\./);
if(_51[_51.length-1]=="*"){
_51.pop();
}
return dojo.evalObjPath(_51.join("."),true);
};
dojo.hostenv.findModule=function(_52,_53){
var lmn=(new String(_52)).toLowerCase();
if(this.loaded_modules_[lmn]){
return this.loaded_modules_[lmn];
}
var _55=dojo.evalObjPath(_52);
if((_52)&&(typeof _55!="undefined")&&(_55)){
this.loaded_modules_[lmn]=_55;
return _55;
}
if(_53){
dojo.raise("no loaded module named '"+_52+"'");
}
return null;
};
if(typeof window=="undefined"){
dojo.raise("no window object");
}
(function(){
if(djConfig.allowQueryConfig){
var _56=document.location.toString();
var _57=_56.split("?",2);
if(_57.length>1){
var _58=_57[1];
var _59=_58.split("&");
for(var x in _59){
var sp=_59[x].split("=");
if((sp[0].length>9)&&(sp[0].substr(0,9)=="djConfig.")){
var opt=sp[0].substr(9);
try{
djConfig[opt]=eval(sp[1]);
}
catch(e){
djConfig[opt]=sp[1];
}
}
}
}
}
if(((djConfig["baseScriptUri"]=="")||(djConfig["baseRelativePath"]==""))&&(document&&document.getElementsByTagName)){
var _5d=document.getElementsByTagName("script");
var _5e=/(__package__|dojo)\.js([\?\.]|$)/i;
for(var i=0;i<_5d.length;i++){
var src=_5d[i].getAttribute("src");
if(!src){
continue;
}
var m=src.match(_5e);
if(m){
root=src.substring(0,m.index);
if(!this["djConfig"]){
djConfig={};
}
if(djConfig["baseScriptUri"]==""){
djConfig["baseScriptUri"]=root;
}
if(djConfig["baseRelativePath"]==""){
djConfig["baseRelativePath"]=root;
}
break;
}
}
}
var dr=dojo.render;
var drh=dojo.render.html;
var dua=drh.UA=navigator.userAgent;
var dav=drh.AV=navigator.appVersion;
var t=true;
var f=false;
drh.capable=t;
drh.support.builtin=t;
dr.ver=parseFloat(drh.AV);
dr.os.mac=dav.indexOf("Macintosh")>=0;
dr.os.win=dav.indexOf("Windows")>=0;
dr.os.linux=dav.indexOf("X11")>=0;
drh.opera=dua.indexOf("Opera")>=0;
drh.khtml=(dav.indexOf("Konqueror")>=0)||(dav.indexOf("Safari")>=0);
drh.safari=dav.indexOf("Safari")>=0;
var _68=dua.indexOf("Gecko");
drh.mozilla=drh.moz=(_68>=0)&&(!drh.khtml);
if(drh.mozilla){
drh.geckoVersion=dua.substring(_68+6,_68+14);
}
drh.ie=(document.all)&&(!drh.opera);
drh.ie50=drh.ie&&dav.indexOf("MSIE 5.0")>=0;
drh.ie55=drh.ie&&dav.indexOf("MSIE 5.5")>=0;
drh.ie60=drh.ie&&dav.indexOf("MSIE 6.0")>=0;
dr.vml.capable=drh.ie;
dr.svg.capable=f;
dr.svg.support.plugin=f;
dr.svg.support.builtin=f;
dr.svg.adobe=f;
if(document.implementation&&document.implementation.hasFeature&&document.implementation.hasFeature("org.w3c.dom.svg","1.0")){
dr.svg.capable=t;
dr.svg.support.builtin=t;
dr.svg.support.plugin=f;
dr.svg.adobe=f;
}else{
if(navigator.mimeTypes&&navigator.mimeTypes.length>0){
var _69=navigator.mimeTypes["image/svg+xml"]||navigator.mimeTypes["image/svg"]||navigator.mimeTypes["image/svg-xml"];
if(_69){
dr.svg.adobe=_69&&_69.enabledPlugin&&_69.enabledPlugin.description&&(_69.enabledPlugin.description.indexOf("Adobe")>-1);
if(dr.svg.adobe){
dr.svg.capable=t;
dr.svg.support.plugin=t;
}
}
}else{
if(drh.ie&&dr.os.win){
var _69=f;
try{
var _6a=new ActiveXObject("Adobe.SVGCtl");
_69=t;
}
catch(e){
}
if(_69){
dr.svg.capable=t;
dr.svg.support.plugin=t;
dr.svg.adobe=t;
}
}else{
dr.svg.capable=f;
dr.svg.support.plugin=f;
dr.svg.adobe=f;
}
}
}
})();
dojo.hostenv.startPackage("dojo.hostenv");
dojo.hostenv.name_="browser";
dojo.hostenv.searchIds=[];
var DJ_XMLHTTP_PROGIDS=["Msxml2.XMLHTTP","Microsoft.XMLHTTP","Msxml2.XMLHTTP.4.0"];
dojo.hostenv.getXmlhttpObject=function(){
var _6b=null;
var _6c=null;
try{
_6b=new XMLHttpRequest();
}
catch(e){
}
if(!_6b){
for(var i=0;i<3;++i){
var _6e=DJ_XMLHTTP_PROGIDS[i];
try{
_6b=new ActiveXObject(_6e);
}
catch(e){
_6c=e;
}
if(_6b){
DJ_XMLHTTP_PROGIDS=[_6e];
break;
}
}
}
if(!_6b){
return dojo.raise("XMLHTTP not available",_6c);
}
return _6b;
};
dojo.hostenv.getText=function(uri,_70,_71){
var _72=this.getXmlhttpObject();
if(_70){
_72.onreadystatechange=function(){
if((4==_72.readyState)&&(_72["status"])){
if(_72.status==200){
_70(_72.responseText);
}
}
};
}
_72.open("GET",uri,_70?true:false);
_72.send(null);
if(_70){
return null;
}
return _72.responseText;
};
dojo.hostenv.defaultDebugContainerId="dojoDebug";
dojo.hostenv._println_buffer=[];
dojo.hostenv._println_safe=false;
dojo.hostenv.println=function(_73){
if(!dojo.hostenv._println_safe){
dojo.hostenv._println_buffer.push(_73);
}else{
try{
var _74=document.getElementById(djConfig.debugContainerId?djConfig.debugContainerId:dojo.hostenv.defaultDebugContainerId);
if(!_74){
_74=document.getElementsByTagName("body")[0]||document.body;
}
var div=document.createElement("div");
div.appendChild(document.createTextNode(_73));
_74.appendChild(div);
}
catch(e){
try{
document.write("<div>"+_73+"</div>");
}
catch(e2){
window.status=_73;
}
}
}
};
dojo.addOnLoad(function(){
dojo.hostenv._println_safe=true;
while(dojo.hostenv._println_buffer.length>0){
dojo.hostenv.println(dojo.hostenv._println_buffer.shift());
}
});
function dj_addNodeEvtHdlr(_76,_77,fp,_79){
var _7a=_76["on"+_77]||function(){
};
_76["on"+_77]=function(){
fp.apply(_76,arguments);
_7a.apply(_76,arguments);
};
return true;
}
dj_addNodeEvtHdlr(window,"load",function(){
if(dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
dojo.hostenv.modulesLoaded();
});
dojo.hostenv.makeWidgets=function(){
var _7b=[];
if(djConfig.searchIds&&djConfig.searchIds.length>0){
_7b=_7b.concat(djConfig.searchIds);
}
if(dojo.hostenv.searchIds&&dojo.hostenv.searchIds.length>0){
_7b=_7b.concat(dojo.hostenv.searchIds);
}
if((djConfig.parseWidgets)||(_7b.length>0)){
if(dojo.evalObjPath("dojo.widget.Parse")){
try{
var _7c=new dojo.xml.Parse();
if(_7b.length>0){
for(var x=0;x<_7b.length;x++){
var _7e=document.getElementById(_7b[x]);
if(!_7e){
continue;
}
var _7f=_7c.parseElement(_7e,null,true);
dojo.widget.getParser().createComponents(_7f);
}
}else{
if(djConfig.parseWidgets){
var _7f=_7c.parseElement(document.getElementsByTagName("body")[0]||document.body,null,true);
dojo.widget.getParser().createComponents(_7f);
}
}
}
catch(e){
dojo.debug("auto-build-widgets error:",e);
}
}
}
};
dojo.hostenv.modulesLoadedListeners.push(function(){
if(!dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
});
try{
if(dojo.render.html.ie){
document.write("<style>v:*{ behavior:url(#default#VML); }</style>");
document.write("<xml:namespace ns=\"urn:schemas-microsoft-com:vml\" prefix=\"v\"/>");
}
}
catch(e){
}
dojo.hostenv.writeIncludes=function(){
};
dojo.hostenv.byId=dojo.byId=function(id,doc){
if(typeof id=="string"||id instanceof String){
if(!doc){
doc=document;
}
return doc.getElementById(id);
}
return id;
};
dojo.hostenv.byIdArray=dojo.byIdArray=function(){
var ids=[];
for(var i=0;i<arguments.length;i++){
if((arguments[i] instanceof Array)||(typeof arguments[i]=="array")){
for(var j=0;j<arguments[i].length;j++){
ids=ids.concat(dojo.hostenv.byIdArray(arguments[i][j]));
}
}else{
ids.push(dojo.hostenv.byId(arguments[i]));
}
}
return ids;
};
dojo.hostenv.conditionalLoadModule=function(_85){
var _86=_85["common"]||[];
var _87=(_85[dojo.hostenv.name_])?_86.concat(_85[dojo.hostenv.name_]||[]):_86.concat(_85["default"]||[]);
for(var x=0;x<_87.length;x++){
var _89=_87[x];
if(_89.constructor==Array){
dojo.hostenv.loadModule.apply(dojo.hostenv,_89);
}else{
dojo.hostenv.loadModule(_89);
}
}
};
dojo.hostenv.require=dojo.hostenv.loadModule;
dojo.require=function(){
dojo.hostenv.loadModule.apply(dojo.hostenv,arguments);
};
dojo.requireAfter=dojo.require;
dojo.requireIf=function(){
if((arguments[0]===true)||(arguments[0]=="common")||(dojo.render[arguments[0]].capable)){
var _8a=[];
for(var i=1;i<arguments.length;i++){
_8a.push(arguments[i]);
}
dojo.require.apply(dojo,_8a);
}
};
dojo.requireAfterIf=dojo.requireIf;
dojo.conditionalRequire=dojo.requireIf;
dojo.kwCompoundRequire=function(){
dojo.hostenv.conditionalLoadModule.apply(dojo.hostenv,arguments);
};
dojo.hostenv.provide=dojo.hostenv.startPackage;
dojo.provide=function(){
return dojo.hostenv.startPackage.apply(dojo.hostenv,arguments);
};
dojo.setModulePrefix=function(_8c,_8d){
return dojo.hostenv.setModulePrefix(_8c,_8d);
};
dojo.profile={start:function(){
},end:function(){
},dump:function(){
}};
dojo.exists=function(obj,_8f){
var p=_8f.split(".");
for(var i=0;i<p.length;i++){
if(!(obj[p[i]])){
return false;
}
obj=obj[p[i]];
}
return true;
};
dojo.provide("dojo.lang");
dojo.provide("dojo.AdapterRegistry");
dojo.provide("dojo.lang.Lang");
dojo.lang.mixin=function(obj,_93){
var _94={};
for(var x in _93){
if(typeof _94[x]=="undefined"||_94[x]!=_93[x]){
obj[x]=_93[x];
}
}
if(dojo.render.html.ie&&dojo.lang.isFunction(_93["toString"])&&_93["toString"]!=obj["toString"]){
obj.toString=_93.toString;
}
return obj;
};
dojo.lang.extend=function(_96,_97){
this.mixin(_96.prototype,_97);
};
dojo.lang.extendPrototype=function(obj,_99){
this.extend(obj.constructor,_99);
};
dojo.lang.anonCtr=0;
dojo.lang.anon={};
dojo.lang.nameAnonFunc=function(_9a,_9b){
var nso=(_9b||dojo.lang.anon);
if((dj_global["djConfig"])&&(djConfig["slowAnonFuncLookups"]==true)){
for(var x in nso){
if(nso[x]===_9a){
return x;
}
}
}
var ret="__"+dojo.lang.anonCtr++;
while(typeof nso[ret]!="undefined"){
ret="__"+dojo.lang.anonCtr++;
}
nso[ret]=_9a;
return ret;
};
dojo.lang.hitch=function(_9f,_a0){
if(dojo.lang.isString(_a0)){
var fcn=_9f[_a0];
}else{
var fcn=_a0;
}
return function(){
return fcn.apply(_9f,arguments);
};
};
dojo.lang.forward=function(_a2){
return function(){
return this[_a2].apply(this,arguments);
};
};
dojo.lang.curry=function(ns,_a4){
var _a5=[];
ns=ns||dj_global;
if(dojo.lang.isString(_a4)){
_a4=ns[_a4];
}
for(var x=2;x<arguments.length;x++){
_a5.push(arguments[x]);
}
var _a7=_a4.length-_a5.length;
function gather(_a8,_a9,_aa){
var _ab=_aa;
var _ac=_a9.slice(0);
for(var x=0;x<_a8.length;x++){
_ac.push(_a8[x]);
}
_aa=_aa-_a8.length;
if(_aa<=0){
var res=_a4.apply(ns,_ac);
_aa=_ab;
return res;
}else{
return function(){
return gather(arguments,_ac,_aa);
};
}
}
return gather([],_a5,_a7);
};
dojo.lang.curryArguments=function(ns,_b0,_b1,_b2){
var _b3=[];
var x=_b2||0;
for(x=_b2;x<_b1.length;x++){
_b3.push(_b1[x]);
}
return dojo.lang.curry.apply(dojo.lang,[ns,_b0].concat(_b3));
};
dojo.lang.setTimeout=function(_b5,_b6){
var _b7=window,argsStart=2;
if(!dojo.lang.isFunction(_b5)){
_b7=_b5;
_b5=_b6;
_b6=arguments[2];
argsStart++;
}
if(dojo.lang.isString(_b5)){
_b5=_b7[_b5];
}
var _b8=[];
for(var i=argsStart;i<arguments.length;i++){
_b8.push(arguments[i]);
}
return setTimeout(function(){
_b5.apply(_b7,_b8);
},_b6);
};
dojo.lang.isObject=function(wh){
return typeof wh=="object"||dojo.lang.isArray(wh)||dojo.lang.isFunction(wh);
};
dojo.lang.isArray=function(wh){
return (wh instanceof Array||typeof wh=="array");
};
dojo.lang.isArrayLike=function(wh){
if(dojo.lang.isString(wh)){
return false;
}
if(dojo.lang.isArray(wh)){
return true;
}
if(typeof wh!="undefined"&&wh&&dojo.lang.isNumber(wh.length)&&isFinite(wh.length)){
return true;
}
return false;
};
dojo.lang.isFunction=function(wh){
return (wh instanceof Function||typeof wh=="function");
};
dojo.lang.isString=function(wh){
return (wh instanceof String||typeof wh=="string");
};
dojo.lang.isAlien=function(wh){
return !dojo.lang.isFunction()&&/\{\s*\[native code\]\s*\}/.test(String(wh));
};
dojo.lang.isBoolean=function(wh){
return (wh instanceof Boolean||typeof wh=="boolean");
};
dojo.lang.isNumber=function(wh){
return (wh instanceof Number||typeof wh=="number");
};
dojo.lang.isUndefined=function(wh){
return ((wh==undefined)&&(typeof wh=="undefined"));
};
dojo.lang.whatAmI=function(wh){
try{
if(dojo.lang.isArray(wh)){
return "array";
}
if(dojo.lang.isFunction(wh)){
return "function";
}
if(dojo.lang.isString(wh)){
return "string";
}
if(dojo.lang.isNumber(wh)){
return "number";
}
if(dojo.lang.isBoolean(wh)){
return "boolean";
}
if(dojo.lang.isAlien(wh)){
return "alien";
}
if(dojo.lang.isUndefined(wh)){
return "undefined";
}
for(var _c4 in dojo.lang.whatAmI.custom){
if(dojo.lang.whatAmI.custom[_c4](wh)){
return _c4;
}
}
if(dojo.lang.isObject(wh)){
return "object";
}
}
catch(E){
}
return "unknown";
};
dojo.lang.whatAmI.custom={};
dojo.lang.find=function(arr,val,_c7){
if(!dojo.lang.isArrayLike(arr)&&dojo.lang.isArrayLike(val)){
var a=arr;
arr=val;
val=a;
}
var _c9=dojo.lang.isString(arr);
if(_c9){
arr=arr.split("");
}
if(_c7){
for(var i=0;i<arr.length;++i){
if(arr[i]===val){
return i;
}
}
}else{
for(var i=0;i<arr.length;++i){
if(arr[i]==val){
return i;
}
}
}
return -1;
};
dojo.lang.indexOf=dojo.lang.find;
dojo.lang.findLast=function(arr,val,_cd){
if(!dojo.lang.isArrayLike(arr)&&dojo.lang.isArrayLike(val)){
var a=arr;
arr=val;
val=a;
}
var _cf=dojo.lang.isString(arr);
if(_cf){
arr=arr.split("");
}
if(_cd){
for(var i=arr.length-1;i>=0;i--){
if(arr[i]===val){
return i;
}
}
}else{
for(var i=arr.length-1;i>=0;i--){
if(arr[i]==val){
return i;
}
}
}
return -1;
};
dojo.lang.lastIndexOf=dojo.lang.findLast;
dojo.lang.inArray=function(arr,val){
return dojo.lang.find(arr,val)>-1;
};
dojo.lang.getNameInObj=function(ns,_d4){
if(!ns){
ns=dj_global;
}
for(var x in ns){
if(ns[x]===_d4){
return new String(x);
}
}
return null;
};
dojo.lang.has=function(obj,_d7){
return (typeof obj[_d7]!=="undefined");
};
dojo.lang.isEmpty=function(obj){
if(dojo.lang.isObject(obj)){
var tmp={};
var _da=0;
for(var x in obj){
if(obj[x]&&(!tmp[x])){
_da++;
break;
}
}
return (_da==0);
}else{
if(dojo.lang.isArrayLike(obj)||dojo.lang.isString(obj)){
return obj.length==0;
}
}
};
dojo.lang.forEach=function(arr,_dd,_de){
var _df=dojo.lang.isString(arr);
if(_df){
arr=arr.split("");
}
var il=arr.length;
for(var i=0;i<((_de)?il:arr.length);i++){
if(_dd(arr[i],i,arr)=="break"){
break;
}
}
};
dojo.lang.map=function(arr,obj,_e4){
var _e5=dojo.lang.isString(arr);
if(_e5){
arr=arr.split("");
}
if(dojo.lang.isFunction(obj)&&(!_e4)){
_e4=obj;
obj=dj_global;
}else{
if(dojo.lang.isFunction(obj)&&_e4){
var _e6=obj;
obj=_e4;
_e4=_e6;
}
}
if(Array.map){
var _e7=Array.map(arr,_e4,obj);
}else{
var _e7=[];
for(var i=0;i<arr.length;++i){
_e7.push(_e4.call(obj,arr[i]));
}
}
if(_e5){
return _e7.join("");
}else{
return _e7;
}
};
dojo.lang.tryThese=function(){
for(var x=0;x<arguments.length;x++){
try{
if(typeof arguments[x]=="function"){
var ret=(arguments[x]());
if(ret){
return ret;
}
}
}
catch(e){
dojo.debug(e);
}
}
};
dojo.lang.delayThese=function(_eb,cb,_ed,_ee){
if(!_eb.length){
if(typeof _ee=="function"){
_ee();
}
return;
}
if((typeof _ed=="undefined")&&(typeof cb=="number")){
_ed=cb;
cb=function(){
};
}else{
if(!cb){
cb=function(){
};
if(!_ed){
_ed=0;
}
}
}
setTimeout(function(){
(_eb.shift())();
cb();
dojo.lang.delayThese(_eb,cb,_ed,_ee);
},_ed);
};
dojo.lang.shallowCopy=function(obj){
var ret={},key;
for(key in obj){
if(dojo.lang.isUndefined(ret[key])){
ret[key]=obj[key];
}
}
return ret;
};
dojo.lang.every=function(arr,_f2,_f3){
var _f4=dojo.lang.isString(arr);
if(_f4){
arr=arr.split("");
}
if(Array.every){
return Array.every(arr,_f2,_f3);
}else{
if(!_f3){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_f3=dj_global;
}
for(var i=0;i<arr.length;i++){
if(!_f2.call(_f3,arr[i],i,arr)){
return false;
}
}
return true;
}
};
dojo.lang.some=function(arr,_f7,_f8){
var _f9=dojo.lang.isString(arr);
if(_f9){
arr=arr.split("");
}
if(Array.some){
return Array.some(arr,_f7,_f8);
}else{
if(!_f8){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_f8=dj_global;
}
for(var i=0;i<arr.length;i++){
if(_f7.call(_f8,arr[i],i,arr)){
return true;
}
}
return false;
}
};
dojo.lang.filter=function(arr,_fc,_fd){
var _fe=dojo.lang.isString(arr);
if(_fe){
arr=arr.split("");
}
if(Array.filter){
var _ff=Array.filter(arr,_fc,_fd);
}else{
if(!_fd){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_fd=dj_global;
}
var _ff=[];
for(var i=0;i<arr.length;i++){
if(_fc.call(_fd,arr[i],i,arr)){
_ff.push(arr[i]);
}
}
}
if(_fe){
return _ff.join("");
}else{
return _ff;
}
};
dojo.AdapterRegistry=function(){
this.pairs=[];
};
dojo.lang.extend(dojo.AdapterRegistry,{register:function(name,_102,wrap,_104){
if(_104){
this.pairs.unshift([name,_102,wrap]);
}else{
this.pairs.push([name,_102,wrap]);
}
},match:function(){
for(var i=0;i<this.pairs.length;i++){
var pair=this.pairs[i];
if(pair[1].apply(this,arguments)){
return pair[2].apply(this,arguments);
}
}
throw new Error("No match found");
},unregister:function(name){
for(var i=0;i<this.pairs.length;i++){
var pair=this.pairs[i];
if(pair[0]==name){
this.pairs.splice(i,1);
return true;
}
}
return false;
}});
dojo.lang.reprRegistry=new dojo.AdapterRegistry();
dojo.lang.registerRepr=function(name,_10b,wrap,_10d){
dojo.lang.reprRegistry.register(name,_10b,wrap,_10d);
};
dojo.lang.repr=function(obj){
if(typeof (obj)=="undefined"){
return "undefined";
}else{
if(obj===null){
return "null";
}
}
try{
if(typeof (obj["__repr__"])=="function"){
return obj["__repr__"]();
}else{
if((typeof (obj["repr"])=="function")&&(obj.repr!=arguments.callee)){
return obj["repr"]();
}
}
return dojo.lang.reprRegistry.match(obj);
}
catch(e){
if(typeof (obj.NAME)=="string"&&(obj.toString==Function.prototype.toString||obj.toString==Object.prototype.toString)){
return o.NAME;
}
}
if(typeof (obj)=="function"){
obj=(obj+"").replace(/^\s+/,"");
var idx=obj.indexOf("{");
if(idx!=-1){
obj=obj.substr(0,idx)+"{...}";
}
}
return obj+"";
};
dojo.lang.reprArrayLike=function(arr){
try{
var na=dojo.lang.map(arr,dojo.lang.repr);
return "["+na.join(", ")+"]";
}
catch(e){
}
};
dojo.lang.reprString=function(str){
return ("\""+str.replace(/(["\\])/g,"\\$1")+"\"").replace(/[\f]/g,"\\f").replace(/[\b]/g,"\\b").replace(/[\n]/g,"\\n").replace(/[\t]/g,"\\t").replace(/[\r]/g,"\\r");
};
dojo.lang.reprNumber=function(num){
return num+"";
};
(function(){
var m=dojo.lang;
m.registerRepr("arrayLike",m.isArrayLike,m.reprArrayLike);
m.registerRepr("string",m.isString,m.reprString);
m.registerRepr("numbers",m.isNumber,m.reprNumber);
m.registerRepr("boolean",m.isBoolean,m.reprNumber);
})();
dojo.lang.unnest=function(){
var out=[];
for(var i=0;i<arguments.length;i++){
if(dojo.lang.isArrayLike(arguments[i])){
var add=dojo.lang.unnest.apply(this,arguments[i]);
out=out.concat(add);
}else{
out.push(arguments[i]);
}
}
return out;
};
dojo.lang.firstValued=function(){
for(var i=0;i<arguments.length;i++){
if(typeof arguments[i]!="undefined"){
return arguments[i];
}
}
return undefined;
};
dojo.lang.toArray=function(_119,_11a){
var _11b=[];
for(var i=_11a||0;i<_119.length;i++){
_11b.push(_119[i]);
}
return _11b;
};
dojo.provide("dojo.dom");
dojo.require("dojo.lang");
dojo.dom.ELEMENT_NODE=1;
dojo.dom.ATTRIBUTE_NODE=2;
dojo.dom.TEXT_NODE=3;
dojo.dom.CDATA_SECTION_NODE=4;
dojo.dom.ENTITY_REFERENCE_NODE=5;
dojo.dom.ENTITY_NODE=6;
dojo.dom.PROCESSING_INSTRUCTION_NODE=7;
dojo.dom.COMMENT_NODE=8;
dojo.dom.DOCUMENT_NODE=9;
dojo.dom.DOCUMENT_TYPE_NODE=10;
dojo.dom.DOCUMENT_FRAGMENT_NODE=11;
dojo.dom.NOTATION_NODE=12;
dojo.dom.dojoml="http://www.dojotoolkit.org/2004/dojoml";
dojo.dom.xmlns={svg:"http://www.w3.org/2000/svg",smil:"http://www.w3.org/2001/SMIL20/",mml:"http://www.w3.org/1998/Math/MathML",cml:"http://www.xml-cml.org",xlink:"http://www.w3.org/1999/xlink",xhtml:"http://www.w3.org/1999/xhtml",xul:"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul",xbl:"http://www.mozilla.org/xbl",fo:"http://www.w3.org/1999/XSL/Format",xsl:"http://www.w3.org/1999/XSL/Transform",xslt:"http://www.w3.org/1999/XSL/Transform",xi:"http://www.w3.org/2001/XInclude",xforms:"http://www.w3.org/2002/01/xforms",saxon:"http://icl.com/saxon",xalan:"http://xml.apache.org/xslt",xsd:"http://www.w3.org/2001/XMLSchema",dt:"http://www.w3.org/2001/XMLSchema-datatypes",xsi:"http://www.w3.org/2001/XMLSchema-instance",rdf:"http://www.w3.org/1999/02/22-rdf-syntax-ns#",rdfs:"http://www.w3.org/2000/01/rdf-schema#",dc:"http://purl.org/dc/elements/1.1/",dcq:"http://purl.org/dc/qualifiers/1.0","soap-env":"http://schemas.xmlsoap.org/soap/envelope/",wsdl:"http://schemas.xmlsoap.org/wsdl/",AdobeExtensions:"http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"};
dojo.dom.isNode=dojo.lang.isDomNode=function(wh){
if(typeof Element=="object"){
try{
return wh instanceof Element;
}
catch(E){
}
}else{
return wh&&!isNaN(wh.nodeType);
}
};
dojo.lang.whatAmI.custom["node"]=dojo.dom.isNode;
dojo.dom.getTagName=function(node){
var _11f=node.tagName;
if(_11f.substr(0,5).toLowerCase()!="dojo:"){
if(_11f.substr(0,4).toLowerCase()=="dojo"){
return "dojo:"+_11f.substring(4).toLowerCase();
}
var djt=node.getAttribute("dojoType")||node.getAttribute("dojotype");
if(djt){
return "dojo:"+djt.toLowerCase();
}
if((node.getAttributeNS)&&(node.getAttributeNS(this.dojoml,"type"))){
return "dojo:"+node.getAttributeNS(this.dojoml,"type").toLowerCase();
}
try{
djt=node.getAttribute("dojo:type");
}
catch(e){
}
if(djt){
return "dojo:"+djt.toLowerCase();
}
if((!dj_global["djConfig"])||(!djConfig["ignoreClassNames"])){
var _121=node.className||node.getAttribute("class");
if((_121)&&(_121.indexOf)&&(_121.indexOf("dojo-")!=-1)){
var _122=_121.split(" ");
for(var x=0;x<_122.length;x++){
if((_122[x].length>5)&&(_122[x].indexOf("dojo-")>=0)){
return "dojo:"+_122[x].substr(5).toLowerCase();
}
}
}
}
}
return _11f.toLowerCase();
};
dojo.dom.getUniqueId=function(){
do{
var id="dj_unique_"+(++arguments.callee._idIncrement);
}while(document.getElementById(id));
return id;
};
dojo.dom.getUniqueId._idIncrement=0;
dojo.dom.firstElement=dojo.dom.getFirstChildElement=function(_125,_126){
var node=_125.firstChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.nextSibling;
}
if(_126&&node&&node.tagName&&node.tagName.toLowerCase()!=_126.toLowerCase()){
node=dojo.dom.nextElement(node,_126);
}
return node;
};
dojo.dom.lastElement=dojo.dom.getLastChildElement=function(_128,_129){
var node=_128.lastChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.previousSibling;
}
if(_129&&node&&node.tagName&&node.tagName.toLowerCase()!=_129.toLowerCase()){
node=dojo.dom.prevElement(node,_129);
}
return node;
};
dojo.dom.nextElement=dojo.dom.getNextSiblingElement=function(node,_12c){
if(!node){
return null;
}
do{
node=node.nextSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_12c&&_12c.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.nextElement(node,_12c);
}
return node;
};
dojo.dom.prevElement=dojo.dom.getPreviousSiblingElement=function(node,_12e){
if(!node){
return null;
}
if(_12e){
_12e=_12e.toLowerCase();
}
do{
node=node.previousSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_12e&&_12e.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.prevElement(node,_12e);
}
return node;
};
dojo.dom.moveChildren=function(_12f,_130,trim){
var _132=0;
if(trim){
while(_12f.hasChildNodes()&&_12f.firstChild.nodeType==dojo.dom.TEXT_NODE){
_12f.removeChild(_12f.firstChild);
}
while(_12f.hasChildNodes()&&_12f.lastChild.nodeType==dojo.dom.TEXT_NODE){
_12f.removeChild(_12f.lastChild);
}
}
while(_12f.hasChildNodes()){
_130.appendChild(_12f.firstChild);
_132++;
}
return _132;
};
dojo.dom.copyChildren=function(_133,_134,trim){
var _136=_133.cloneNode(true);
return this.moveChildren(_136,_134,trim);
};
dojo.dom.removeChildren=function(node){
var _138=node.childNodes.length;
while(node.hasChildNodes()){
node.removeChild(node.firstChild);
}
return _138;
};
dojo.dom.replaceChildren=function(node,_13a){
dojo.dom.removeChildren(node);
node.appendChild(_13a);
};
dojo.dom.removeNode=function(node){
if(node&&node.parentNode){
return node.parentNode.removeChild(node);
}
};
dojo.dom.getAncestors=function(node,_13d,_13e){
var _13f=[];
var _140=dojo.lang.isFunction(_13d);
while(node){
if(!_140||_13d(node)){
_13f.push(node);
}
if(_13e&&_13f.length>0){
return _13f[0];
}
node=node.parentNode;
}
if(_13e){
return null;
}
return _13f;
};
dojo.dom.getAncestorsByTag=function(node,tag,_143){
tag=tag.toLowerCase();
return dojo.dom.getAncestors(node,function(el){
return ((el.tagName)&&(el.tagName.toLowerCase()==tag));
},_143);
};
dojo.dom.getFirstAncestorByTag=function(node,tag){
return dojo.dom.getAncestorsByTag(node,tag,true);
};
dojo.dom.isDescendantOf=function(node,_148,_149){
if(_149&&node){
node=node.parentNode;
}
while(node){
if(node==_148){
return true;
}
node=node.parentNode;
}
return false;
};
dojo.dom.innerXML=function(node){
if(node.innerXML){
return node.innerXML;
}else{
if(typeof XMLSerializer!="undefined"){
return (new XMLSerializer()).serializeToString(node);
}
}
};
dojo.dom.createDocumentFromText=function(str,_14c){
if(!_14c){
_14c="text/xml";
}
if(typeof DOMParser!="undefined"){
var _14d=new DOMParser();
return _14d.parseFromString(str,_14c);
}else{
if(typeof ActiveXObject!="undefined"){
var _14e=new ActiveXObject("Microsoft.XMLDOM");
if(_14e){
_14e.async=false;
_14e.loadXML(str);
return _14e;
}else{
dojo.debug("toXml didn't work?");
}
}else{
if(document.createElement){
var tmp=document.createElement("xml");
tmp.innerHTML=str;
if(document.implementation&&document.implementation.createDocument){
var _150=document.implementation.createDocument("foo","",null);
for(var i=0;i<tmp.childNodes.length;i++){
_150.importNode(tmp.childNodes.item(i),true);
}
return _150;
}
return tmp.document&&tmp.document.firstChild?tmp.document.firstChild:tmp;
}
}
}
return null;
};
dojo.dom.prependChild=function(node,_153){
if(_153.firstChild){
_153.insertBefore(node,_153.firstChild);
}else{
_153.appendChild(node);
}
return true;
};
dojo.dom.insertBefore=function(node,ref,_156){
if(_156!=true&&(node===ref||node.nextSibling===ref)){
return false;
}
var _157=ref.parentNode;
_157.insertBefore(node,ref);
return true;
};
dojo.dom.insertAfter=function(node,ref,_15a){
var pn=ref.parentNode;
if(ref==pn.lastChild){
if((_15a!=true)&&(node===ref)){
return false;
}
pn.appendChild(node);
}else{
return this.insertBefore(node,ref.nextSibling,_15a);
}
return true;
};
dojo.dom.insertAtPosition=function(node,ref,_15e){
if((!node)||(!ref)||(!_15e)){
return false;
}
switch(_15e.toLowerCase()){
case "before":
return dojo.dom.insertBefore(node,ref);
case "after":
return dojo.dom.insertAfter(node,ref);
case "first":
if(ref.firstChild){
return dojo.dom.insertBefore(node,ref.firstChild);
}else{
ref.appendChild(node);
return true;
}
break;
default:
ref.appendChild(node);
return true;
}
};
dojo.dom.insertAtIndex=function(node,_160,_161){
var _162=_160.childNodes;
if(!_162.length){
_160.appendChild(node);
return true;
}
var _163=null;
for(var i=0;i<_162.length;i++){
var _165=_162.item(i)["getAttribute"]?parseInt(_162.item(i).getAttribute("dojoinsertionindex")):-1;
if(_165<_161){
_163=_162.item(i);
}
}
if(_163){
return dojo.dom.insertAfter(node,_163);
}else{
return dojo.dom.insertBefore(node,_162.item(0));
}
};
dojo.dom.textContent=function(node,text){
if(text){
dojo.dom.replaceChildren(node,document.createTextNode(text));
return text;
}else{
var _168="";
if(node==null){
return _168;
}
for(var i=0;i<node.childNodes.length;i++){
switch(node.childNodes[i].nodeType){
case 1:
case 5:
_168+=dojo.dom.textContent(node.childNodes[i]);
break;
case 3:
case 2:
case 4:
_168+=node.childNodes[i].nodeValue;
break;
default:
break;
}
}
return _168;
}
};
dojo.dom.collectionToArray=function(_16a){
dojo.deprecated("dojo.dom.collectionToArray","use dojo.lang.toArray instead");
return dojo.lang.toArray(_16a);
};
dojo.dom.hasParent=function(node){
if(!node||!node.parentNode||(node.parentNode&&!node.parentNode.tagName)){
return false;
}
return true;
};
dojo.dom.isTag=function(node){
if(node&&node.tagName){
var arr=dojo.lang.toArray(arguments,1);
return arr[dojo.lang.find(node.tagName,arr)]||"";
}
return "";
};
dojo.provide("dojo.uri.Uri");
dojo.uri=new function(){
this.joinPath=function(){
var arr=[];
for(var i=0;i<arguments.length;i++){
arr.push(arguments[i]);
}
return arr.join("/").replace(/\/{2,}/g,"/").replace(/((https*|ftps*):)/i,"$1/");
};
this.dojoUri=function(uri){
return new dojo.uri.Uri(dojo.hostenv.getBaseScriptUri(),uri);
};
this.Uri=function(){
var uri=arguments[0];
for(var i=1;i<arguments.length;i++){
if(!arguments[i]){
continue;
}
var _173=new dojo.uri.Uri(arguments[i].toString());
var _174=new dojo.uri.Uri(uri.toString());
if(_173.path==""&&_173.scheme==null&&_173.authority==null&&_173.query==null){
if(_173.fragment!=null){
_174.fragment=_173.fragment;
}
_173=_174;
}else{
if(_173.scheme==null){
_173.scheme=_174.scheme;
if(_173.authority==null){
_173.authority=_174.authority;
if(_173.path.charAt(0)!="/"){
var path=_174.path.substring(0,_174.path.lastIndexOf("/")+1)+_173.path;
var segs=path.split("/");
for(var j=0;j<segs.length;j++){
if(segs[j]=="."){
if(j==segs.length-1){
segs[j]="";
}else{
segs.splice(j,1);
j--;
}
}else{
if(j>0&&!(j==1&&segs[0]=="")&&segs[j]==".."&&segs[j-1]!=".."){
if(j==segs.length-1){
segs.splice(j,1);
segs[j-1]="";
}else{
segs.splice(j-1,2);
j-=2;
}
}
}
}
_173.path=segs.join("/");
}
}
}
}
uri="";
if(_173.scheme!=null){
uri+=_173.scheme+":";
}
if(_173.authority!=null){
uri+="//"+_173.authority;
}
uri+=_173.path;
if(_173.query!=null){
uri+="?"+_173.query;
}
if(_173.fragment!=null){
uri+="#"+_173.fragment;
}
}
this.uri=uri.toString();
var _178="^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?$";
var r=this.uri.match(new RegExp(_178));
this.scheme=r[2]||(r[1]?"":null);
this.authority=r[4]||(r[3]?"":null);
this.path=r[5];
this.query=r[7]||(r[6]?"":null);
this.fragment=r[9]||(r[8]?"":null);
if(this.authority!=null){
_178="^((([^:]+:)?([^@]+))@)?([^:]*)(:([0-9]+))?$";
r=this.authority.match(new RegExp(_178));
this.user=r[3]||null;
this.password=r[4]||null;
this.host=r[5];
this.port=r[7]||null;
}
this.toString=function(){
return this.uri;
};
};
};
dojo.provide("dojo.string");
dojo.require("dojo.lang");
dojo.string.trim=function(str,wh){
if(!dojo.lang.isString(str)){
return str;
}
if(!str.length){
return str;
}
if(wh>0){
return str.replace(/^\s+/,"");
}else{
if(wh<0){
return str.replace(/\s+$/,"");
}else{
return str.replace(/^\s+|\s+$/g,"");
}
}
};
dojo.string.trimStart=function(str){
return dojo.string.trim(str,1);
};
dojo.string.trimEnd=function(str){
return dojo.string.trim(str,-1);
};
dojo.string.paramString=function(str,_17f,_180){
for(var name in _17f){
var re=new RegExp("\\%\\{"+name+"\\}","g");
str=str.replace(re,_17f[name]);
}
if(_180){
str=str.replace(/%\{([^\}\s]+)\}/g,"");
}
return str;
};
dojo.string.capitalize=function(str){
if(!dojo.lang.isString(str)){
return "";
}
if(arguments.length==0){
str=this;
}
var _184=str.split(" ");
var _185="";
var len=_184.length;
for(var i=0;i<len;i++){
var word=_184[i];
word=word.charAt(0).toUpperCase()+word.substring(1,word.length);
_185+=word;
if(i<len-1){
_185+=" ";
}
}
return new String(_185);
};
dojo.string.isBlank=function(str){
if(!dojo.lang.isString(str)){
return true;
}
return (dojo.string.trim(str).length==0);
};
dojo.string.encodeAscii=function(str){
if(!dojo.lang.isString(str)){
return str;
}
var ret="";
var _18c=escape(str);
var _18d,re=/%u([0-9A-F]{4})/i;
while((_18d=_18c.match(re))){
var num=Number("0x"+_18d[1]);
var _18f=escape("&#"+num+";");
ret+=_18c.substring(0,_18d.index)+_18f;
_18c=_18c.substring(_18d.index+_18d[0].length);
}
ret+=_18c.replace(/\+/g,"%2B");
return ret;
};
dojo.string.summary=function(str,len){
if(!len||str.length<=len){
return str;
}else{
return str.substring(0,len).replace(/\.+$/,"")+"...";
}
};
dojo.string.escape=function(type,str){
var args=[];
for(var i=1;i<arguments.length;i++){
args.push(arguments[i]);
}
switch(type.toLowerCase()){
case "xml":
case "html":
case "xhtml":
return dojo.string.escapeXml.apply(this,args);
case "sql":
return dojo.string.escapeSql.apply(this,args);
case "regexp":
case "regex":
return dojo.string.escapeRegExp.apply(this,args);
case "javascript":
case "jscript":
case "js":
return dojo.string.escapeJavaScript.apply(this,args);
case "ascii":
return dojo.string.encodeAscii.apply(this,args);
default:
return str;
}
};
dojo.string.escapeXml=function(str,_197){
str=str.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;").replace(/"/gm,"&quot;");
if(!_197){
str=str.replace(/'/gm,"&#39;");
}
return str;
};
dojo.string.escapeSql=function(str){
return str.replace(/'/gm,"''");
};
dojo.string.escapeRegExp=function(str){
return str.replace(/\\/gm,"\\\\").replace(/([\f\b\n\t\r])/gm,"\\$1");
};
dojo.string.escapeJavaScript=function(str){
return str.replace(/(["'\f\b\n\t\r])/gm,"\\$1");
};
dojo.string.repeat=function(str,_19c,_19d){
var out="";
for(var i=0;i<_19c;i++){
out+=str;
if(_19d&&i<_19c-1){
out+=_19d;
}
}
return out;
};
dojo.string.endsWith=function(str,end,_1a2){
if(_1a2){
str=str.toLowerCase();
end=end.toLowerCase();
}
return str.lastIndexOf(end)==str.length-end.length;
};
dojo.string.endsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.endsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.startsWith=function(str,_1a6,_1a7){
if(_1a7){
str=str.toLowerCase();
_1a6=_1a6.toLowerCase();
}
return str.indexOf(_1a6)==0;
};
dojo.string.startsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.startsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.has=function(str){
for(var i=1;i<arguments.length;i++){
if(str.indexOf(arguments[i]>-1)){
return true;
}
}
return false;
};
dojo.string.pad=function(str,len,c,dir){
var out=String(str);
if(!c){
c="0";
}
if(!dir){
dir=1;
}
while(out.length<len){
if(dir>0){
out=c+out;
}else{
out+=c;
}
}
return out;
};
dojo.string.padLeft=function(str,len,c){
return dojo.string.pad(str,len,c,1);
};
dojo.string.padRight=function(str,len,c){
return dojo.string.pad(str,len,c,-1);
};
dojo.string.normalizeNewlines=function(text,_1b8){
if(_1b8=="\n"){
text=text.replace(/\r\n/g,"\n");
text=text.replace(/\r/g,"\n");
}else{
if(_1b8=="\r"){
text=text.replace(/\r\n/g,"\r");
text=text.replace(/\n/g,"\r");
}else{
text=text.replace(/([^\r])\n/g,"$1\r\n");
text=text.replace(/\r([^\n])/g,"\r\n$1");
}
}
return text;
};
dojo.string.splitEscaped=function(str,_1ba){
var _1bb=[];
for(var i=0,prevcomma=0;i<str.length;i++){
if(str.charAt(i)=="\\"){
i++;
continue;
}
if(str.charAt(i)==_1ba){
_1bb.push(str.substring(prevcomma,i));
prevcomma=i+1;
}
}
_1bb.push(str.substr(prevcomma));
return _1bb;
};
dojo.string.addToPrototype=function(){
for(var _1bd in dojo.string){
if(dojo.lang.isFunction(dojo.string[_1bd])){
var func=(function(){
var meth=_1bd;
switch(meth){
case "addToPrototype":
return null;
break;
case "escape":
return function(type){
return dojo.string.escape(type,this);
};
break;
default:
return function(){
var args=[this];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
dojo.debug(args);
return dojo.string[meth].apply(dojo.string,args);
};
}
})();
if(func){
String.prototype[_1bd]=func;
}
}
}
};
dojo.provide("dojo.math");
dojo.math.degToRad=function(x){
return (x*Math.PI)/180;
};
dojo.math.radToDeg=function(x){
return (x*180)/Math.PI;
};
dojo.math.factorial=function(n){
if(n<1){
return 0;
}
var _1c6=1;
for(var i=1;i<=n;i++){
_1c6*=i;
}
return _1c6;
};
dojo.math.permutations=function(n,k){
if(n==0||k==0){
return 1;
}
return (dojo.math.factorial(n)/dojo.math.factorial(n-k));
};
dojo.math.combinations=function(n,r){
if(n==0||r==0){
return 1;
}
return (dojo.math.factorial(n)/(dojo.math.factorial(n-r)*dojo.math.factorial(r)));
};
dojo.math.bernstein=function(t,n,i){
return (dojo.math.combinations(n,i)*Math.pow(t,i)*Math.pow(1-t,n-i));
};
dojo.math.gaussianRandom=function(){
var k=2;
do{
var i=2*Math.random()-1;
var j=2*Math.random()-1;
k=i*i+j*j;
}while(k>=1);
k=Math.sqrt((-2*Math.log(k))/k);
return i*k;
};
dojo.math.mean=function(){
var _1d2=dojo.lang.isArray(arguments[0])?arguments[0]:arguments;
var mean=0;
for(var i=0;i<_1d2.length;i++){
mean+=_1d2[i];
}
return mean/_1d2.length;
};
dojo.math.round=function(_1d5,_1d6){
if(!_1d6){
var _1d7=1;
}else{
var _1d7=Math.pow(10,_1d6);
}
return Math.round(_1d5*_1d7)/_1d7;
};
dojo.math.sd=function(){
var _1d8=dojo.lang.isArray(arguments[0])?arguments[0]:arguments;
return Math.sqrt(dojo.math.variance(_1d8));
};
dojo.math.variance=function(){
var _1d9=dojo.lang.isArray(arguments[0])?arguments[0]:arguments;
var mean=0,squares=0;
for(var i=0;i<_1d9.length;i++){
mean+=_1d9[i];
squares+=Math.pow(_1d9[i],2);
}
return (squares/_1d9.length)-Math.pow(mean/_1d9.length,2);
};
dojo.math.range=function(a,b,step){
if(arguments.length<2){
b=a;
a=0;
}
if(arguments.length<3){
step=1;
}
var _1df=[];
if(step>0){
for(var i=a;i<b;i+=step){
_1df.push(i);
}
}else{
if(step<0){
for(var i=a;i>b;i+=step){
_1df.push(i);
}
}else{
throw new Error("dojo.math.range: step must be non-zero");
}
}
return _1df;
};
dojo.provide("dojo.graphics.color");
dojo.require("dojo.lang");
dojo.require("dojo.string");
dojo.require("dojo.math");
dojo.graphics.color.Color=function(r,g,b,a){
if(dojo.lang.isArray(r)){
this.r=r[0];
this.g=r[1];
this.b=r[2];
this.a=r[3]||1;
}else{
if(dojo.lang.isString(r)){
var rgb=dojo.graphics.color.extractRGB(r);
this.r=rgb[0];
this.g=rgb[1];
this.b=rgb[2];
this.a=g||1;
}else{
if(r instanceof dojo.graphics.color.Color){
this.r=r.r;
this.b=r.b;
this.g=r.g;
this.a=r.a;
}else{
this.r=r;
this.g=g;
this.b=b;
this.a=a;
}
}
}
};
dojo.lang.extend(dojo.graphics.color.Color,{toRgb:function(_1e6){
if(_1e6){
return this.toRgba();
}else{
return [this.r,this.g,this.b];
}
},toRgba:function(){
return [this.r,this.g,this.b,this.a];
},toHex:function(){
return dojo.graphics.color.rgb2hex(this.toRgb());
},toCss:function(){
return "rgb("+this.toRgb().join()+")";
},toString:function(){
return this.toHex();
},toHsv:function(){
return dojo.graphics.color.rgb2hsv(this.toRgb());
},toHsl:function(){
return dojo.graphics.color.rgb2hsl(this.toRgb());
},blend:function(_1e7,_1e8){
return dojo.graphics.color.blend(this.toRgb(),new Color(_1e7).toRgb(),_1e8);
}});
dojo.graphics.color.named={white:[255,255,255],black:[0,0,0],red:[255,0,0],green:[0,255,0],blue:[0,0,255],navy:[0,0,128],gray:[128,128,128],silver:[192,192,192]};
dojo.graphics.color.blend=function(a,b,_1eb){
if(typeof a=="string"){
return dojo.graphics.color.blendHex(a,b,_1eb);
}
if(!_1eb){
_1eb=0;
}else{
if(_1eb>1){
_1eb=1;
}else{
if(_1eb<-1){
_1eb=-1;
}
}
}
var c=new Array(3);
for(var i=0;i<3;i++){
var half=Math.abs(a[i]-b[i])/2;
c[i]=Math.floor(Math.min(a[i],b[i])+half+(half*_1eb));
}
return c;
};
dojo.graphics.color.blendHex=function(a,b,_1f1){
return dojo.graphics.color.rgb2hex(dojo.graphics.color.blend(dojo.graphics.color.hex2rgb(a),dojo.graphics.color.hex2rgb(b),_1f1));
};
dojo.graphics.color.extractRGB=function(_1f2){
var hex="0123456789abcdef";
_1f2=_1f2.toLowerCase();
if(_1f2.indexOf("rgb")==0){
var _1f4=_1f2.match(/rgba*\((\d+), *(\d+), *(\d+)/i);
var ret=_1f4.splice(1,3);
return ret;
}else{
var _1f6=dojo.graphics.color.hex2rgb(_1f2);
if(_1f6){
return _1f6;
}else{
return dojo.graphics.color.named[_1f2]||[255,255,255];
}
}
};
dojo.graphics.color.hex2rgb=function(hex){
var _1f8="0123456789ABCDEF";
var rgb=new Array(3);
if(hex.indexOf("#")==0){
hex=hex.substring(1);
}
hex=hex.toUpperCase();
if(hex.replace(new RegExp("["+_1f8+"]","g"),"")!=""){
return null;
}
if(hex.length==3){
rgb[0]=hex.charAt(0)+hex.charAt(0);
rgb[1]=hex.charAt(1)+hex.charAt(1);
rgb[2]=hex.charAt(2)+hex.charAt(2);
}else{
rgb[0]=hex.substring(0,2);
rgb[1]=hex.substring(2,4);
rgb[2]=hex.substring(4);
}
for(var i=0;i<rgb.length;i++){
rgb[i]=_1f8.indexOf(rgb[i].charAt(0))*16+_1f8.indexOf(rgb[i].charAt(1));
}
return rgb;
};
dojo.graphics.color.rgb2hex=function(r,g,b){
if(dojo.lang.isArray(r)){
g=r[1]||0;
b=r[2]||0;
r=r[0]||0;
}
return ["#",dojo.string.pad(r.toString(16),2),dojo.string.pad(g.toString(16),2),dojo.string.pad(b.toString(16),2)].join("");
};
dojo.graphics.color.rgb2hsv=function(r,g,b){
if(dojo.lang.isArray(r)){
b=r[2]||0;
g=r[1]||0;
r=r[0]||0;
}
var h=null;
var s=null;
var v=null;
var min=Math.min(r,g,b);
v=Math.max(r,g,b);
var _205=v-min;
s=(v==0)?0:_205/v;
if(s==0){
h=0;
}else{
if(r==v){
h=60*(g-b)/_205;
}else{
if(g==v){
h=120+60*(b-r)/_205;
}else{
if(b==v){
h=240+60*(r-g)/_205;
}
}
}
if(h<0){
h+=360;
}
}
h=(h==0)?360:Math.ceil((h/360)*255);
s=Math.ceil(s*255);
return [h,s,v];
};
dojo.graphics.color.hsv2rgb=function(h,s,v){
if(dojo.lang.isArray(h)){
v=h[2]||0;
s=h[1]||0;
h=h[0]||0;
}
h=(h/255)*360;
if(h==360){
h=0;
}
s=s/255;
v=v/255;
var r=null;
var g=null;
var b=null;
if(s==0){
r=v;
g=v;
b=v;
}else{
var _20c=h/60;
var i=Math.floor(_20c);
var f=_20c-i;
var p=v*(1-s);
var q=v*(1-(s*f));
var t=v*(1-(s*(1-f)));
switch(i){
case 0:
r=v;
g=t;
b=p;
break;
case 1:
r=q;
g=v;
b=p;
break;
case 2:
r=p;
g=v;
b=t;
break;
case 3:
r=p;
g=q;
b=v;
break;
case 4:
r=t;
g=p;
b=v;
break;
case 5:
r=v;
g=p;
b=q;
break;
}
}
r=Math.ceil(r*255);
g=Math.ceil(g*255);
b=Math.ceil(b*255);
return [r,g,b];
};
dojo.graphics.color.rgb2hsl=function(r,g,b){
if(dojo.lang.isArray(r)){
b=r[2]||0;
g=r[1]||0;
r=r[0]||0;
}
r/=255;
g/=255;
b/=255;
var h=null;
var s=null;
var l=null;
var min=Math.min(r,g,b);
var max=Math.max(r,g,b);
var _21a=max-min;
l=(min+max)/2;
s=0;
if((l>0)&&(l<1)){
s=_21a/((l<0.5)?(2*l):(2-2*l));
}
h=0;
if(_21a>0){
if((max==r)&&(max!=g)){
h+=(g-b)/_21a;
}
if((max==g)&&(max!=b)){
h+=(2+(b-r)/_21a);
}
if((max==b)&&(max!=r)){
h+=(4+(r-g)/_21a);
}
h*=60;
}
h=(h==0)?360:Math.ceil((h/360)*255);
s=Math.ceil(s*255);
l=Math.ceil(l*255);
return [h,s,l];
};
dojo.graphics.color.hsl2rgb=function(h,s,l){
if(dojo.lang.isArray(h)){
l=h[2]||0;
s=h[1]||0;
h=h[0]||0;
}
h=(h/255)*360;
if(h==360){
h=0;
}
s=s/255;
l=l/255;
while(h<0){
h+=360;
}
while(h>360){
h-=360;
}
if(h<120){
r=(120-h)/60;
g=h/60;
b=0;
}else{
if(h<240){
r=0;
g=(240-h)/60;
b=(h-120)/60;
}else{
r=(h-240)/60;
g=0;
b=(360-h)/60;
}
}
r=Math.min(r,1);
g=Math.min(g,1);
b=Math.min(b,1);
r=2*s*r+(1-s);
g=2*s*g+(1-s);
b=2*s*b+(1-s);
if(l<0.5){
r=l*r;
g=l*g;
b=l*b;
}else{
r=(1-l)*r+2*l-1;
g=(1-l)*g+2*l-1;
b=(1-l)*b+2*l-1;
}
r=Math.ceil(r*255);
g=Math.ceil(g*255);
b=Math.ceil(b*255);
return [r,g,b];
};
dojo.graphics.color.hsl2hex=function(h,s,l){
var rgb=dojo.graphics.color.hsl2rgb(h,s,l);
return dojo.graphics.color.rgb2hex(rgb[0],rgb[1],rgb[2]);
};
dojo.graphics.color.hex2hsl=function(hex){
var rgb=dojo.graphics.color.hex2rgb(hex);
return dojo.graphics.color.rgb2hsl(rgb[0],rgb[1],rgb[2]);
};
dojo.provide("dojo.style");
dojo.require("dojo.dom");
dojo.require("dojo.uri.Uri");
dojo.require("dojo.graphics.color");
dojo.style.boxSizing={marginBox:"margin-box",borderBox:"border-box",paddingBox:"padding-box",contentBox:"content-box"};
dojo.style.getBoxSizing=function(node){
if(dojo.render.html.ie||dojo.render.html.opera){
var cm=document["compatMode"];
if(cm=="BackCompat"||cm=="QuirksMode"){
return dojo.style.boxSizing.borderBox;
}else{
return dojo.style.boxSizing.contentBox;
}
}else{
if(arguments.length==0){
node=document.documentElement;
}
var _226=dojo.style.getStyle(node,"-moz-box-sizing");
if(!_226){
_226=dojo.style.getStyle(node,"box-sizing");
}
return (_226?_226:dojo.style.boxSizing.contentBox);
}
};
dojo.style.isBorderBox=function(node){
return (dojo.style.getBoxSizing(node)==dojo.style.boxSizing.borderBox);
};
dojo.style.getUnitValue=function(_228,_229,_22a){
var _22b={value:0,units:"px"};
var s=dojo.style.getComputedStyle(_228,_229);
if(s==""||(s=="auto"&&_22a)){
return _22b;
}
if(dojo.lang.isUndefined(s)){
_22b.value=NaN;
}else{
var _22d=s.match(/([\d.]+)([a-z%]*)/i);
if(!_22d){
_22b.value=NaN;
}else{
_22b.value=Number(_22d[1]);
_22b.units=_22d[2].toLowerCase();
}
}
return _22b;
};
dojo.style.getPixelValue=function(_22e,_22f,_230){
var _231=dojo.style.getUnitValue(_22e,_22f,_230);
if(isNaN(_231.value)){
return 0;
}
if((_231.value)&&(_231.units!="px")){
return NaN;
}
return _231.value;
};
dojo.style.getNumericStyle=dojo.style.getPixelValue;
dojo.style.isPositionAbsolute=function(node){
return (dojo.style.getComputedStyle(node,"position")=="absolute");
};
dojo.style.getMarginWidth=function(node){
var _234=dojo.style.isPositionAbsolute(node);
var left=dojo.style.getPixelValue(node,"margin-left",_234);
var _236=dojo.style.getPixelValue(node,"margin-right",_234);
return left+_236;
};
dojo.style.getBorderWidth=function(node){
var left=(dojo.style.getStyle(node,"border-left-style")=="none"?0:dojo.style.getPixelValue(node,"border-left-width"));
var _239=(dojo.style.getStyle(node,"border-right-style")=="none"?0:dojo.style.getPixelValue(node,"border-right-width"));
return left+_239;
};
dojo.style.getPaddingWidth=function(node){
var left=dojo.style.getPixelValue(node,"padding-left",true);
var _23c=dojo.style.getPixelValue(node,"padding-right",true);
return left+_23c;
};
dojo.style.getContentWidth=function(node){
return node.offsetWidth-dojo.style.getPaddingWidth(node)-dojo.style.getBorderWidth(node);
};
dojo.style.getInnerWidth=function(node){
return node.offsetWidth;
};
dojo.style.getOuterWidth=function(node){
return dojo.style.getInnerWidth(node)+dojo.style.getMarginWidth(node);
};
dojo.style.setOuterWidth=function(node,_241){
if(!dojo.style.isBorderBox(node)){
_241-=dojo.style.getPaddingWidth(node)+dojo.style.getBorderWidth(node);
}
_241-=dojo.style.getMarginWidth(node);
if(!isNaN(_241)&&_241>0){
node.style.width=_241+"px";
return true;
}else{
return false;
}
};
dojo.style.getContentBoxWidth=dojo.style.getContentWidth;
dojo.style.getBorderBoxWidth=dojo.style.getInnerWidth;
dojo.style.getMarginBoxWidth=dojo.style.getOuterWidth;
dojo.style.setMarginBoxWidth=dojo.style.setOuterWidth;
dojo.style.getMarginHeight=function(node){
var _243=dojo.style.isPositionAbsolute(node);
var top=dojo.style.getPixelValue(node,"margin-top",_243);
var _245=dojo.style.getPixelValue(node,"margin-bottom",_243);
return top+_245;
};
dojo.style.getBorderHeight=function(node){
var top=(dojo.style.getStyle(node,"border-top-style")=="none"?0:dojo.style.getPixelValue(node,"border-top-width"));
var _248=(dojo.style.getStyle(node,"border-bottom-style")=="none"?0:dojo.style.getPixelValue(node,"border-bottom-width"));
return top+_248;
};
dojo.style.getPaddingHeight=function(node){
var top=dojo.style.getPixelValue(node,"padding-top",true);
var _24b=dojo.style.getPixelValue(node,"padding-bottom",true);
return top+_24b;
};
dojo.style.getContentHeight=function(node){
return node.offsetHeight-dojo.style.getPaddingHeight(node)-dojo.style.getBorderHeight(node);
};
dojo.style.getInnerHeight=function(node){
return node.offsetHeight;
};
dojo.style.getOuterHeight=function(node){
return dojo.style.getInnerHeight(node)+dojo.style.getMarginHeight(node);
};
dojo.style.setOuterHeight=function(node,_250){
if(!dojo.style.isBorderBox(node)){
_250-=dojo.style.getPaddingHeight(node)+dojo.style.getBorderHeight(node);
}
_250-=dojo.style.getMarginHeight(node);
if(!isNaN(_250)&&_250>0){
node.style.height=_250+"px";
return true;
}else{
return false;
}
};
dojo.style.setContentWidth=function(node,_252){
if(dojo.style.isBorderBox(node)){
_252+=dojo.style.getPaddingWidth(node)+dojo.style.getBorderWidth(node);
}
if(!isNaN(_252)&&_252>0){
node.style.width=_252+"px";
return true;
}else{
return false;
}
};
dojo.style.setContentHeight=function(node,_254){
if(dojo.style.isBorderBox(node)){
_254+=dojo.style.getPaddingHeight(node)+dojo.style.getBorderHeight(node);
}
if(!isNaN(_254)&&_254>0){
node.style.height=_254+"px";
return true;
}else{
return false;
}
};
dojo.style.getContentBoxHeight=dojo.style.getContentHeight;
dojo.style.getBorderBoxHeight=dojo.style.getInnerHeight;
dojo.style.getMarginBoxHeight=dojo.style.getOuterHeight;
dojo.style.setMarginBoxHeight=dojo.style.setOuterHeight;
dojo.style.getTotalOffset=function(node,type,_257){
var _258=(type=="top")?"offsetTop":"offsetLeft";
var _259=(type=="top")?"scrollTop":"scrollLeft";
var _25a=(type=="top")?"y":"x";
var _25b=0;
if(node["offsetParent"]){
if(dojo.render.html.safari&&node.style.getPropertyValue("position")=="absolute"&&node.parentNode==dojo.html.body()){
var _25c=dojo.html.body();
}else{
var _25c=dojo.html.body().parentNode;
}
if(_257&&node.parentNode!=document.body){
_25b-=dojo.style.sumAncestorProperties(node,_259);
}
do{
_25b+=node[_258];
node=node.offsetParent;
}while(node!=_25c&&node!=null);
}else{
if(node[_25a]){
_25b+=node[_25a];
}
}
return _25b;
};
dojo.style.sumAncestorProperties=function(node,prop){
if(!node){
return 0;
}
var _25f=0;
while(node){
var val=node[prop];
if(val){
_25f+=val-0;
}
node=node.parentNode;
}
return _25f;
};
dojo.style.totalOffsetLeft=function(node,_262){
return dojo.style.getTotalOffset(node,"left",_262);
};
dojo.style.getAbsoluteX=dojo.style.totalOffsetLeft;
dojo.style.totalOffsetTop=function(node,_264){
return dojo.style.getTotalOffset(node,"top",_264);
};
dojo.style.getAbsoluteY=dojo.style.totalOffsetTop;
dojo.style.getAbsolutePosition=function(node,_266){
var _267=[dojo.style.getAbsoluteX(node,_266),dojo.style.getAbsoluteY(node,_266)];
_267.x=_267[0];
_267.y=_267[1];
return _267;
};
dojo.style.styleSheet=null;
dojo.style.insertCssRule=function(_268,_269,_26a){
if(!dojo.style.styleSheet){
if(document.createStyleSheet){
dojo.style.styleSheet=document.createStyleSheet();
}else{
if(document.styleSheets[0]){
dojo.style.styleSheet=document.styleSheets[0];
}else{
return null;
}
}
}
if(arguments.length<3){
if(dojo.style.styleSheet.cssRules){
_26a=dojo.style.styleSheet.cssRules.length;
}else{
if(dojo.style.styleSheet.rules){
_26a=dojo.style.styleSheet.rules.length;
}else{
return null;
}
}
}
if(dojo.style.styleSheet.insertRule){
var rule=_268+" { "+_269+" }";
return dojo.style.styleSheet.insertRule(rule,_26a);
}else{
if(dojo.style.styleSheet.addRule){
return dojo.style.styleSheet.addRule(_268,_269,_26a);
}else{
return null;
}
}
};
dojo.style.removeCssRule=function(_26c){
if(!dojo.style.styleSheet){
dojo.debug("no stylesheet defined for removing rules");
return false;
}
if(dojo.render.html.ie){
if(!_26c){
_26c=dojo.style.styleSheet.rules.length;
dojo.style.styleSheet.removeRule(_26c);
}
}else{
if(document.styleSheets[0]){
if(!_26c){
_26c=dojo.style.styleSheet.cssRules.length;
}
dojo.style.styleSheet.deleteRule(_26c);
}
}
return true;
};
dojo.style.insertCssFile=function(URI,doc,_26f){
if(!URI){
return;
}
if(!doc){
doc=document;
}
if(doc.baseURI){
URI=new dojo.uri.Uri(doc.baseURI,URI);
}
if(_26f&&doc.styleSheets){
var loc=location.href.split("#")[0].substring(0,location.href.indexOf(location.pathname));
for(var i=0;i<doc.styleSheets.length;i++){
if(doc.styleSheets[i].href&&URI.toString()==new dojo.uri.Uri(doc.styleSheets[i].href.toString())){
return;
}
}
}
var file=doc.createElement("link");
file.setAttribute("type","text/css");
file.setAttribute("rel","stylesheet");
file.setAttribute("href",URI);
var head=doc.getElementsByTagName("head")[0];
if(head){
head.appendChild(file);
}
};
dojo.style.getBackgroundColor=function(node){
var _275;
do{
_275=dojo.style.getStyle(node,"background-color");
if(_275.toLowerCase()=="rgba(0, 0, 0, 0)"){
_275="transparent";
}
if(node==document.getElementsByTagName("body")[0]){
node=null;
break;
}
node=node.parentNode;
}while(node&&dojo.lang.inArray(_275,["transparent",""]));
if(_275=="transparent"){
_275=[255,255,255,0];
}else{
_275=dojo.graphics.color.extractRGB(_275);
}
return _275;
};
dojo.style.getComputedStyle=function(_276,_277,_278){
var _279=_278;
if(_276.style.getPropertyValue){
_279=_276.style.getPropertyValue(_277);
}
if(!_279){
if(document.defaultView){
var cs=document.defaultView.getComputedStyle(_276,"");
if(cs){
_279=cs.getPropertyValue(_277);
}
}else{
if(_276.currentStyle){
_279=_276.currentStyle[dojo.style.toCamelCase(_277)];
}
}
}
return _279;
};
dojo.style.getStyle=function(_27b,_27c){
var _27d=dojo.style.toCamelCase(_27c);
var _27e=_27b.style[_27d];
return (_27e?_27e:dojo.style.getComputedStyle(_27b,_27c,_27e));
};
dojo.style.toCamelCase=function(_27f){
var arr=_27f.split("-"),cc=arr[0];
for(var i=1;i<arr.length;i++){
cc+=arr[i].charAt(0).toUpperCase()+arr[i].substring(1);
}
return cc;
};
dojo.style.toSelectorCase=function(_282){
return _282.replace(/([A-Z])/g,"-$1").toLowerCase();
};
dojo.style.setOpacity=function setOpacity(node,_284,_285){
node=dojo.byId(node);
var h=dojo.render.html;
if(!_285){
if(_284>=1){
if(h.ie){
dojo.style.clearOpacity(node);
return;
}else{
_284=0.999999;
}
}else{
if(_284<0){
_284=0;
}
}
}
if(h.ie){
if(node.nodeName.toLowerCase()=="tr"){
var tds=node.getElementsByTagName("td");
for(var x=0;x<tds.length;x++){
tds[x].style.filter="Alpha(Opacity="+_284*100+")";
}
}
node.style.filter="Alpha(Opacity="+_284*100+")";
}else{
if(h.moz){
node.style.opacity=_284;
node.style.MozOpacity=_284;
}else{
if(h.safari){
node.style.opacity=_284;
node.style.KhtmlOpacity=_284;
}else{
node.style.opacity=_284;
}
}
}
};
dojo.style.getOpacity=function getOpacity(node){
if(dojo.render.html.ie){
var opac=(node.filters&&node.filters.alpha&&typeof node.filters.alpha.opacity=="number"?node.filters.alpha.opacity:100)/100;
}else{
var opac=node.style.opacity||node.style.MozOpacity||node.style.KhtmlOpacity||1;
}
return opac>=0.999999?1:Number(opac);
};
dojo.style.clearOpacity=function clearOpacity(node){
var h=dojo.render.html;
if(h.ie){
if(node.filters&&node.filters.alpha){
node.style.filter="";
}
}else{
if(h.moz){
node.style.opacity=1;
node.style.MozOpacity=1;
}else{
if(h.safari){
node.style.opacity=1;
node.style.KhtmlOpacity=1;
}else{
node.style.opacity=1;
}
}
}
};
dojo.provide("dojo.html");
dojo.require("dojo.dom");
dojo.require("dojo.style");
dojo.require("dojo.string");
dojo.lang.mixin(dojo.html,dojo.dom);
dojo.lang.mixin(dojo.html,dojo.style);
dojo.html.clearSelection=function(){
try{
if(window["getSelection"]){
if(dojo.render.html.safari){
window.getSelection().collapse();
}else{
window.getSelection().removeAllRanges();
}
}else{
if(document.selection){
if(document.selection.empty){
document.selection.empty();
}else{
if(document.selection.clear){
document.selection.clear();
}
}
}
}
return true;
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.html.disableSelection=function(_28d){
_28d=dojo.byId(_28d)||dojo.html.body();
var h=dojo.render.html;
if(h.mozilla){
_28d.style.MozUserSelect="none";
}else{
if(h.safari){
_28d.style.KhtmlUserSelect="none";
}else{
if(h.ie){
_28d.unselectable="on";
}else{
return false;
}
}
}
return true;
};
dojo.html.enableSelection=function(_28f){
_28f=dojo.byId(_28f)||dojo.html.body();
var h=dojo.render.html;
if(h.mozilla){
_28f.style.MozUserSelect="";
}else{
if(h.safari){
_28f.style.KhtmlUserSelect="";
}else{
if(h.ie){
_28f.unselectable="off";
}else{
return false;
}
}
}
return true;
};
dojo.html.selectElement=function(_291){
_291=dojo.byId(_291);
if(document.selection&&dojo.html.body().createTextRange){
var _292=dojo.html.body().createTextRange();
_292.moveToElementText(_291);
_292.select();
}else{
if(window["getSelection"]){
var _293=window.getSelection();
if(_293["selectAllChildren"]){
_293.selectAllChildren(_291);
}
}
}
};
dojo.html.isSelectionCollapsed=function(){
if(document["selection"]){
return document.selection.createRange().text=="";
}else{
if(window["getSelection"]){
var _294=window.getSelection();
if(dojo.lang.isString(_294)){
return _294=="";
}else{
return _294.isCollapsed;
}
}
}
};
dojo.html.getEventTarget=function(evt){
if(!evt){
evt=window.event||{};
}
if(evt.srcElement){
return evt.srcElement;
}else{
if(evt.target){
return evt.target;
}
}
return null;
};
dojo.html.getScrollTop=function(){
return document.documentElement.scrollTop||dojo.html.body().scrollTop||0;
};
dojo.html.getScrollLeft=function(){
return document.documentElement.scrollLeft||dojo.html.body().scrollLeft||0;
};
dojo.html.getDocumentWidth=function(){
dojo.deprecated("dojo.html.getDocument* has been deprecated in favor of dojo.html.getViewport*");
return dojo.html.getViewportWidth();
};
dojo.html.getDocumentHeight=function(){
dojo.deprecated("dojo.html.getDocument* has been deprecated in favor of dojo.html.getViewport*");
return dojo.html.getViewportHeight();
};
dojo.html.getDocumentSize=function(){
dojo.deprecated("dojo.html.getDocument* has been deprecated in favor of dojo.html.getViewport*");
return dojo.html.getViewportSize();
};
dojo.html.getViewportWidth=function(){
var w=0;
if(window.innerWidth){
w=window.innerWidth;
}
if(dojo.exists(document,"documentElement.clientWidth")){
var w2=document.documentElement.clientWidth;
if(!w||w2&&w2<w){
w=w2;
}
return w;
}
if(document.body){
return document.body.clientWidth;
}
return 0;
};
dojo.html.getViewportHeight=function(){
if(window.innerHeight){
return window.innerHeight;
}
if(dojo.exists(document,"documentElement.clientHeight")){
return document.documentElement.clientHeight;
}
if(document.body){
return document.body.clientHeight;
}
return 0;
};
dojo.html.getViewportSize=function(){
var ret=[dojo.html.getViewportWidth(),dojo.html.getViewportHeight()];
ret.w=ret[0];
ret.h=ret[1];
return ret;
};
dojo.html.getScrollOffset=function(){
var ret=[0,0];
if(window.pageYOffset){
ret=[window.pageXOffset,window.pageYOffset];
}else{
if(dojo.exists(document,"documentElement.scrollTop")){
ret=[document.documentElement.scrollLeft,document.documentElement.scrollTop];
}else{
if(document.body){
ret=[document.body.scrollLeft,document.body.scrollTop];
}
}
}
ret.x=ret[0];
ret.y=ret[1];
return ret;
};
dojo.html.getParentOfType=function(node,type){
dojo.deprecated("dojo.html.getParentOfType has been deprecated in favor of dojo.html.getParentByType*");
return dojo.html.getParentByType(node,type);
};
dojo.html.getParentByType=function(node,type){
var _29e=dojo.byId(node);
type=type.toLowerCase();
while((_29e)&&(_29e.nodeName.toLowerCase()!=type)){
if(_29e==(document["body"]||document["documentElement"])){
return null;
}
_29e=_29e.parentNode;
}
return _29e;
};
dojo.html.getAttribute=function(node,attr){
node=dojo.byId(node);
if((!node)||(!node.getAttribute)){
return null;
}
var ta=typeof attr=="string"?attr:new String(attr);
var v=node.getAttribute(ta.toUpperCase());
if((v)&&(typeof v=="string")&&(v!="")){
return v;
}
if(v&&v.value){
return v.value;
}
if((node.getAttributeNode)&&(node.getAttributeNode(ta))){
return (node.getAttributeNode(ta)).value;
}else{
if(node.getAttribute(ta)){
return node.getAttribute(ta);
}else{
if(node.getAttribute(ta.toLowerCase())){
return node.getAttribute(ta.toLowerCase());
}
}
}
return null;
};
dojo.html.hasAttribute=function(node,attr){
node=dojo.byId(node);
return dojo.html.getAttribute(node,attr)?true:false;
};
dojo.html.getClass=function(node){
node=dojo.byId(node);
if(!node){
return "";
}
var cs="";
if(node.className){
cs=node.className;
}else{
if(dojo.html.hasAttribute(node,"class")){
cs=dojo.html.getAttribute(node,"class");
}
}
return dojo.string.trim(cs);
};
dojo.html.getClasses=function(node){
node=dojo.byId(node);
var c=dojo.html.getClass(node);
return (c=="")?[]:c.split(/\s+/g);
};
dojo.html.hasClass=function(node,_2aa){
node=dojo.byId(node);
return dojo.lang.inArray(dojo.html.getClasses(node),_2aa);
};
dojo.html.prependClass=function(node,_2ac){
node=dojo.byId(node);
if(!node){
return false;
}
_2ac+=" "+dojo.html.getClass(node);
return dojo.html.setClass(node,_2ac);
};
dojo.html.addClass=function(node,_2ae){
node=dojo.byId(node);
if(!node){
return false;
}
if(dojo.html.hasClass(node,_2ae)){
return false;
}
_2ae=dojo.string.trim(dojo.html.getClass(node)+" "+_2ae);
return dojo.html.setClass(node,_2ae);
};
dojo.html.setClass=function(node,_2b0){
node=dojo.byId(node);
if(!node){
return false;
}
var cs=new String(_2b0);
try{
if(typeof node.className=="string"){
node.className=cs;
}else{
if(node.setAttribute){
node.setAttribute("class",_2b0);
node.className=cs;
}else{
return false;
}
}
}
catch(e){
dojo.debug("dojo.html.setClass() failed",e);
}
return true;
};
dojo.html.removeClass=function(node,_2b3,_2b4){
node=dojo.byId(node);
if(!node){
return false;
}
var _2b3=dojo.string.trim(new String(_2b3));
try{
var cs=dojo.html.getClasses(node);
var nca=[];
if(_2b4){
for(var i=0;i<cs.length;i++){
if(cs[i].indexOf(_2b3)==-1){
nca.push(cs[i]);
}
}
}else{
for(var i=0;i<cs.length;i++){
if(cs[i]!=_2b3){
nca.push(cs[i]);
}
}
}
dojo.html.setClass(node,nca.join(" "));
}
catch(e){
dojo.debug("dojo.html.removeClass() failed",e);
}
return true;
};
dojo.html.replaceClass=function(node,_2b9,_2ba){
node=dojo.byId(node);
dojo.html.removeClass(node,_2ba);
dojo.html.addClass(node,_2b9);
};
dojo.html.classMatchType={ContainsAll:0,ContainsAny:1,IsOnly:2};
dojo.html.getElementsByClass=function(_2bb,_2bc,_2bd,_2be){
_2bc=dojo.byId(_2bc);
if(!_2bc){
_2bc=document;
}
var _2bf=_2bb.split(/\s+/g);
var _2c0=[];
if(_2be!=1&&_2be!=2){
_2be=0;
}
var _2c1=new RegExp("(\\s|^)(("+_2bf.join(")|(")+"))(\\s|$)");
if(!_2bd){
_2bd="*";
}
var _2c2=_2bc.getElementsByTagName(_2bd);
outer:
for(var i=0;i<_2c2.length;i++){
var node=_2c2[i];
var _2c5=dojo.html.getClasses(node);
if(_2c5.length==0){
continue outer;
}
var _2c6=0;
for(var j=0;j<_2c5.length;j++){
if(_2c1.test(_2c5[j])){
if(_2be==dojo.html.classMatchType.ContainsAny){
_2c0.push(node);
continue outer;
}else{
_2c6++;
}
}else{
if(_2be==dojo.html.classMatchType.IsOnly){
continue outer;
}
}
}
if(_2c6==_2bf.length){
if(_2be==dojo.html.classMatchType.IsOnly&&_2c6==_2c5.length){
_2c0.push(node);
}else{
if(_2be==dojo.html.classMatchType.ContainsAll){
_2c0.push(node);
}
}
}
}
return _2c0;
};
dojo.html.getElementsByClassName=dojo.html.getElementsByClass;
dojo.html.gravity=function(node,e){
node=dojo.byId(node);
var _2ca=e.pageX||e.clientX+dojo.html.body().scrollLeft;
var _2cb=e.pageY||e.clientY+dojo.html.body().scrollTop;
with(dojo.html){
var _2cc=getAbsoluteX(node)+(getInnerWidth(node)/2);
var _2cd=getAbsoluteY(node)+(getInnerHeight(node)/2);
}
with(dojo.html.gravity){
return ((_2ca<_2cc?WEST:EAST)|(_2cb<_2cd?NORTH:SOUTH));
}
};
dojo.html.gravity.NORTH=1;
dojo.html.gravity.SOUTH=1<<1;
dojo.html.gravity.EAST=1<<2;
dojo.html.gravity.WEST=1<<3;
dojo.html.overElement=function(_2ce,e){
_2ce=dojo.byId(_2ce);
var _2d0=e.pageX||e.clientX+dojo.html.body().scrollLeft;
var _2d1=e.pageY||e.clientY+dojo.html.body().scrollTop;
with(dojo.html){
var top=getAbsoluteY(_2ce);
var _2d3=top+getInnerHeight(_2ce);
var left=getAbsoluteX(_2ce);
var _2d5=left+getInnerWidth(_2ce);
}
return (_2d0>=left&&_2d0<=_2d5&&_2d1>=top&&_2d1<=_2d3);
};
dojo.html.renderedTextContent=function(node){
node=dojo.byId(node);
var _2d7="";
if(node==null){
return _2d7;
}
for(var i=0;i<node.childNodes.length;i++){
switch(node.childNodes[i].nodeType){
case 1:
case 5:
var _2d9="unknown";
try{
_2d9=dojo.style.getStyle(node.childNodes[i],"display");
}
catch(E){
}
switch(_2d9){
case "block":
case "list-item":
case "run-in":
case "table":
case "table-row-group":
case "table-header-group":
case "table-footer-group":
case "table-row":
case "table-column-group":
case "table-column":
case "table-cell":
case "table-caption":
_2d7+="\n";
_2d7+=dojo.html.renderedTextContent(node.childNodes[i]);
_2d7+="\n";
break;
case "none":
break;
default:
if(node.childNodes[i].tagName&&node.childNodes[i].tagName.toLowerCase()=="br"){
_2d7+="\n";
}else{
_2d7+=dojo.html.renderedTextContent(node.childNodes[i]);
}
break;
}
break;
case 3:
case 2:
case 4:
var text=node.childNodes[i].nodeValue;
var _2db="unknown";
try{
_2db=dojo.style.getStyle(node,"text-transform");
}
catch(E){
}
switch(_2db){
case "capitalize":
text=dojo.string.capitalize(text);
break;
case "uppercase":
text=text.toUpperCase();
break;
case "lowercase":
text=text.toLowerCase();
break;
default:
break;
}
switch(_2db){
case "nowrap":
break;
case "pre-wrap":
break;
case "pre-line":
break;
case "pre":
break;
default:
text=text.replace(/\s+/," ");
if(/\s$/.test(_2d7)){
text.replace(/^\s/,"");
}
break;
}
_2d7+=text;
break;
default:
break;
}
}
return _2d7;
};
dojo.html.setActiveStyleSheet=function(_2dc){
var i,a,main;
for(i=0;(a=document.getElementsByTagName("link")[i]);i++){
if(a.getAttribute("rel").indexOf("style")!=-1&&a.getAttribute("title")){
a.disabled=true;
if(a.getAttribute("title")==_2dc){
a.disabled=false;
}
}
}
};
dojo.html.getActiveStyleSheet=function(){
var i,a;
for(i=0;(a=document.getElementsByTagName("link")[i]);i++){
if(a.getAttribute("rel").indexOf("style")!=-1&&a.getAttribute("title")&&!a.disabled){
return a.getAttribute("title");
}
}
return null;
};
dojo.html.getPreferredStyleSheet=function(){
var i,a;
for(i=0;(a=document.getElementsByTagName("link")[i]);i++){
if(a.getAttribute("rel").indexOf("style")!=-1&&a.getAttribute("rel").indexOf("alt")==-1&&a.getAttribute("title")){
return a.getAttribute("title");
}
}
return null;
};
dojo.html.body=function(){
return document.body||document.getElementsByTagName("body")[0];
};
dojo.html.createNodesFromText=function(txt,trim){
if(trim){
txt=dojo.string.trim(txt);
}
var tn=document.createElement("div");
tn.style.visibility="hidden";
document.body.appendChild(tn);
var _2e3="none";
if((/^<t[dh][\s\r\n>]/i).test(dojo.string.trimStart(txt))){
txt="<table><tbody><tr>"+txt+"</tr></tbody></table>";
_2e3="cell";
}else{
if((/^<tr[\s\r\n>]/i).test(dojo.string.trimStart(txt))){
txt="<table><tbody>"+txt+"</tbody></table>";
_2e3="row";
}else{
if((/^<(thead|tbody|tfoot)[\s\r\n>]/i).test(dojo.string.trimStart(txt))){
txt="<table>"+txt+"</table>";
_2e3="section";
}
}
}
tn.innerHTML=txt;
tn.normalize();
var _2e4=null;
switch(_2e3){
case "cell":
_2e4=tn.getElementsByTagName("tr")[0];
break;
case "row":
_2e4=tn.getElementsByTagName("tbody")[0];
break;
case "section":
_2e4=tn.getElementsByTagName("table")[0];
break;
default:
_2e4=tn;
break;
}
var _2e5=[];
for(var x=0;x<_2e4.childNodes.length;x++){
_2e5.push(_2e4.childNodes[x].cloneNode(true));
}
tn.style.display="none";
document.body.removeChild(tn);
return _2e5;
};
if(!dojo.evalObjPath("dojo.dom.createNodesFromText")){
dojo.dom.createNodesFromText=function(){
dojo.deprecated("dojo.dom.createNodesFromText","use dojo.html.createNodesFromText instead");
return dojo.html.createNodesFromText.apply(dojo.html,arguments);
};
}
dojo.html.isVisible=function(node){
node=dojo.byId(node);
return dojo.style.getComputedStyle(node||this.domNode,"display")!="none";
};
dojo.html.show=function(node){
node=dojo.byId(node);
if(node.style){
node.style.display=dojo.lang.inArray(["tr","td","th"],node.tagName.toLowerCase())?"":"block";
}
};
dojo.html.hide=function(node){
node=dojo.byId(node);
if(node.style){
node.style.display="none";
}
};
dojo.html.toggleVisible=function(node){
if(dojo.html.isVisible(node)){
dojo.html.hide(node);
return false;
}else{
dojo.html.show(node);
return true;
}
};
dojo.html.isTag=function(node){
node=dojo.byId(node);
if(node&&node.tagName){
var arr=dojo.lang.map(dojo.lang.toArray(arguments,1),function(a){
return String(a).toLowerCase();
});
return arr[dojo.lang.find(node.tagName.toLowerCase(),arr)]||"";
}
return "";
};
dojo.html.toCoordinateArray=function(_2ee,_2ef){
if(dojo.lang.isArray(_2ee)){
while(_2ee.length<4){
_2ee.push(0);
}
while(_2ee.length>4){
_2ee.pop();
}
var ret=_2ee;
}else{
var node=dojo.byId(_2ee);
var ret=[dojo.html.getAbsoluteX(node,_2ef),dojo.html.getAbsoluteY(node,_2ef),dojo.html.getInnerWidth(node),dojo.html.getInnerHeight(node)];
}
ret.x=ret[0];
ret.y=ret[1];
ret.w=ret[2];
ret.h=ret[3];
return ret;
};
dojo.html.placeOnScreen=function(node,_2f3,_2f4,_2f5,_2f6){
if(dojo.lang.isArray(_2f3)){
_2f6=_2f5;
_2f5=_2f4;
_2f4=_2f3[1];
_2f3=_2f3[0];
}
if(!isNaN(_2f5)){
_2f5=[Number(_2f5),Number(_2f5)];
}else{
if(!dojo.lang.isArray(_2f5)){
_2f5=[0,0];
}
}
var _2f7=dojo.html.getScrollOffset();
var view=dojo.html.getViewportSize();
node=dojo.byId(node);
var w=node.offsetWidth+_2f5[0];
var h=node.offsetHeight+_2f5[1];
if(_2f6){
_2f3-=_2f7.x;
_2f4-=_2f7.y;
}
var x=_2f3+w;
if(x>view.w){
x=view.w-w;
}else{
x=_2f3;
}
x=Math.max(_2f5[0],x)+_2f7.x;
var y=_2f4+h;
if(y>view.h){
y=view.h-h;
}else{
y=_2f4;
}
y=Math.max(_2f5[1],y)+_2f7.y;
node.style.left=x+"px";
node.style.top=y+"px";
var ret=[x,y];
ret.x=x;
ret.y=y;
return ret;
};
dojo.html.placeOnScreenPoint=function(node,_2ff,_300,_301,_302){
if(dojo.lang.isArray(_2ff)){
_302=_301;
_301=_300;
_300=_2ff[1];
_2ff=_2ff[0];
}
var _303=dojo.html.getScrollOffset();
var view=dojo.html.getViewportSize();
node=dojo.byId(node);
var w=node.offsetWidth;
var h=node.offsetHeight;
if(_302){
_2ff-=_303.x;
_300-=_303.y;
}
var x=-1,y=-1;
if(_2ff+w<=view.w&&_300+h<=view.h){
x=_2ff;
y=_300;
}
if((x<0||y<0)&&_2ff<=view.w&&_300+h<=view.h){
x=_2ff-w;
y=_300;
}
if((x<0||y<0)&&_2ff+w<=view.w&&_300<=view.h){
x=_2ff;
y=_300-h;
}
if((x<0||y<0)&&_2ff<=view.w&&_300<=view.h){
x=_2ff-w;
y=_300-h;
}
if(x<0||y<0||(x+w>view.w)||(y+h>view.h)){
return dojo.html.placeOnScreen(node,_2ff,_300,_301,_302);
}
x+=_303.x;
y+=_303.y;
node.style.left=x+"px";
node.style.top=y+"px";
var ret=[x,y];
ret.x=x;
ret.y=y;
return ret;
};
dojo.html.BackgroundIframe=function(){
if(this.ie){
this.iframe=document.createElement("<iframe frameborder='0' src='about:blank'>");
var s=this.iframe.style;
s.position="absolute";
s.left=s.top="0px";
s.zIndex=2;
s.display="none";
dojo.style.setOpacity(this.iframe,0);
dojo.html.body().appendChild(this.iframe);
}else{
this.enabled=false;
}
};
dojo.lang.extend(dojo.html.BackgroundIframe,{ie:dojo.render.html.ie,enabled:true,visibile:false,iframe:null,sizeNode:null,sizeCoords:null,size:function(node){
if(!this.ie||!this.enabled){
return;
}
if(dojo.dom.isNode(node)){
this.sizeNode=node;
}else{
if(arguments.length>0){
this.sizeNode=null;
this.sizeCoords=node;
}
}
this.update();
},update:function(){
if(!this.ie||!this.enabled){
return;
}
if(this.sizeNode){
this.sizeCoords=dojo.html.toCoordinateArray(this.sizeNode,true);
}else{
if(this.sizeCoords){
this.sizeCoords=dojo.html.toCoordinateArray(this.sizeCoords,true);
}else{
return;
}
}
var s=this.iframe.style;
var dims=this.sizeCoords;
s.width=dims.w+"px";
s.height=dims.h+"px";
s.left=dims.x+"px";
s.top=dims.y+"px";
},setZIndex:function(node){
if(!this.ie||!this.enabled){
return;
}
if(dojo.dom.isNode(node)){
this.iframe.zIndex=dojo.html.getStyle(node,"z-index")-1;
}else{
if(!isNaN(node)){
this.iframe.zIndex=node;
}
}
},show:function(node){
if(!this.ie||!this.enabled){
return;
}
this.size(node);
this.iframe.style.display="block";
},hide:function(){
if(!this.ie){
return;
}
var s=this.iframe.style;
s.display="none";
s.width=s.height="1px";
},remove:function(){
dojo.dom.removeNode(this.iframe);
}});
dojo.provide("dojo.math.curves");
dojo.require("dojo.math");
dojo.math.curves={Line:function(_310,end){
this.start=_310;
this.end=end;
this.dimensions=_310.length;
for(var i=0;i<_310.length;i++){
_310[i]=Number(_310[i]);
}
for(var i=0;i<end.length;i++){
end[i]=Number(end[i]);
}
this.getValue=function(n){
var _314=new Array(this.dimensions);
for(var i=0;i<this.dimensions;i++){
_314[i]=((this.end[i]-this.start[i])*n)+this.start[i];
}
return _314;
};
return this;
},Bezier:function(pnts){
this.getValue=function(step){
if(step>=1){
return this.p[this.p.length-1];
}
if(step<=0){
return this.p[0];
}
var _318=new Array(this.p[0].length);
for(var k=0;j<this.p[0].length;k++){
_318[k]=0;
}
for(var j=0;j<this.p[0].length;j++){
var C=0;
var D=0;
for(var i=0;i<this.p.length;i++){
C+=this.p[i][j]*this.p[this.p.length-1][0]*dojo.math.bernstein(step,this.p.length,i);
}
for(var l=0;l<this.p.length;l++){
D+=this.p[this.p.length-1][0]*dojo.math.bernstein(step,this.p.length,l);
}
_318[j]=C/D;
}
return _318;
};
this.p=pnts;
return this;
},CatmullRom:function(pnts,c){
this.getValue=function(step){
var _322=step*(this.p.length-1);
var node=Math.floor(_322);
var _324=_322-node;
var i0=node-1;
if(i0<0){
i0=0;
}
var i=node;
var i1=node+1;
if(i1>=this.p.length){
i1=this.p.length-1;
}
var i2=node+2;
if(i2>=this.p.length){
i2=this.p.length-1;
}
var u=_324;
var u2=_324*_324;
var u3=_324*_324*_324;
var _32c=new Array(this.p[0].length);
for(var k=0;k<this.p[0].length;k++){
var x1=(-this.c*this.p[i0][k])+((2-this.c)*this.p[i][k])+((this.c-2)*this.p[i1][k])+(this.c*this.p[i2][k]);
var x2=(2*this.c*this.p[i0][k])+((this.c-3)*this.p[i][k])+((3-2*this.c)*this.p[i1][k])+(-this.c*this.p[i2][k]);
var x3=(-this.c*this.p[i0][k])+(this.c*this.p[i1][k]);
var x4=this.p[i][k];
_32c[k]=x1*u3+x2*u2+x3*u+x4;
}
return _32c;
};
if(!c){
this.c=0.7;
}else{
this.c=c;
}
this.p=pnts;
return this;
},Arc:function(_332,end,ccw){
var _335=dojo.math.points.midpoint(_332,end);
var _336=dojo.math.points.translate(dojo.math.points.invert(_335),_332);
var rad=Math.sqrt(Math.pow(_336[0],2)+Math.pow(_336[1],2));
var _338=dojo.math.radToDeg(Math.atan(_336[1]/_336[0]));
if(_336[0]<0){
_338-=90;
}else{
_338+=90;
}
dojo.math.curves.CenteredArc.call(this,_335,rad,_338,_338+(ccw?-180:180));
},CenteredArc:function(_339,_33a,_33b,end){
this.center=_339;
this.radius=_33a;
this.start=_33b||0;
this.end=end;
this.getValue=function(n){
var _33e=new Array(2);
var _33f=dojo.math.degToRad(this.start+((this.end-this.start)*n));
_33e[0]=this.center[0]+this.radius*Math.sin(_33f);
_33e[1]=this.center[1]-this.radius*Math.cos(_33f);
return _33e;
};
return this;
},Circle:function(_340,_341){
dojo.math.curves.CenteredArc.call(this,_340,_341,0,360);
return this;
},Path:function(){
var _342=[];
var _343=[];
var _344=[];
var _345=0;
this.add=function(_346,_347){
if(_347<0){
dojo.raise("dojo.math.curves.Path.add: weight cannot be less than 0");
}
_342.push(_346);
_343.push(_347);
_345+=_347;
computeRanges();
};
this.remove=function(_348){
for(var i=0;i<_342.length;i++){
if(_342[i]==_348){
_342.splice(i,1);
_345-=_343.splice(i,1)[0];
break;
}
}
computeRanges();
};
this.removeAll=function(){
_342=[];
_343=[];
_345=0;
};
this.getValue=function(n){
var _34b=false,value=0;
for(var i=0;i<_344.length;i++){
var r=_344[i];
if(n>=r[0]&&n<r[1]){
var subN=(n-r[0])/r[2];
value=_342[i].getValue(subN);
_34b=true;
break;
}
}
if(!_34b){
value=_342[_342.length-1].getValue(1);
}
for(j=0;j<i;j++){
value=dojo.math.points.translate(value,_342[j].getValue(1));
}
return value;
};
function computeRanges(){
var _34f=0;
for(var i=0;i<_343.length;i++){
var end=_34f+_343[i]/_345;
var len=end-_34f;
_344[i]=[_34f,end,len];
_34f=end;
}
}
return this;
}};
dojo.provide("dojo.animation");
dojo.provide("dojo.animation.Animation");
dojo.require("dojo.lang");
dojo.require("dojo.math");
dojo.require("dojo.math.curves");
dojo.animation.Animation=function(_353,_354,_355,_356,rate){
if(dojo.lang.isArray(_353)){
_353=new dojo.math.curves.Line(_353[0],_353[1]);
}
this.curve=_353;
this.duration=_354;
this.repeatCount=_356||0;
this.rate=rate||25;
if(_355){
if(dojo.lang.isFunction(_355.getValue)){
this.accel=_355;
}else{
var i=0.35*_355+0.5;
this.accel=new dojo.math.curves.CatmullRom([[0],[i],[1]],0.45);
}
}
};
dojo.lang.extend(dojo.animation.Animation,{curve:null,duration:0,repeatCount:0,accel:null,onBegin:null,onAnimate:null,onEnd:null,onPlay:null,onPause:null,onStop:null,handler:null,_animSequence:null,_startTime:null,_endTime:null,_lastFrame:null,_timer:null,_percent:0,_active:false,_paused:false,_startRepeatCount:0,play:function(_359){
if(_359){
clearTimeout(this._timer);
this._active=false;
this._paused=false;
this._percent=0;
}else{
if(this._active&&!this._paused){
return;
}
}
this._startTime=new Date().valueOf();
if(this._paused){
this._startTime-=(this.duration*this._percent/100);
}
this._endTime=this._startTime+this.duration;
this._lastFrame=this._startTime;
var e=new dojo.animation.AnimationEvent(this,null,this.curve.getValue(this._percent),this._startTime,this._startTime,this._endTime,this.duration,this._percent,0);
this._active=true;
this._paused=false;
if(this._percent==0){
if(!this._startRepeatCount){
this._startRepeatCount=this.repeatCount;
}
e.type="begin";
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onBegin=="function"){
this.onBegin(e);
}
}
e.type="play";
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onPlay=="function"){
this.onPlay(e);
}
if(this._animSequence){
this._animSequence._setCurrent(this);
}
this._cycle();
},pause:function(){
clearTimeout(this._timer);
if(!this._active){
return;
}
this._paused=true;
var e=new dojo.animation.AnimationEvent(this,"pause",this.curve.getValue(this._percent),this._startTime,new Date().valueOf(),this._endTime,this.duration,this._percent,0);
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onPause=="function"){
this.onPause(e);
}
},playPause:function(){
if(!this._active||this._paused){
this.play();
}else{
this.pause();
}
},gotoPercent:function(pct,_35d){
clearTimeout(this._timer);
this._active=true;
this._paused=true;
this._percent=pct;
if(_35d){
this.play();
}
},stop:function(_35e){
clearTimeout(this._timer);
var step=this._percent/100;
if(_35e){
step=1;
}
var e=new dojo.animation.AnimationEvent(this,"stop",this.curve.getValue(step),this._startTime,new Date().valueOf(),this._endTime,this.duration,this._percent,Math.round(fps));
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onStop=="function"){
this.onStop(e);
}
this._active=false;
this._paused=false;
},status:function(){
if(this._active){
return this._paused?"paused":"playing";
}else{
return "stopped";
}
},_cycle:function(){
clearTimeout(this._timer);
if(this._active){
var curr=new Date().valueOf();
var step=(curr-this._startTime)/(this._endTime-this._startTime);
fps=1000/(curr-this._lastFrame);
this._lastFrame=curr;
if(step>=1){
step=1;
this._percent=100;
}else{
this._percent=step*100;
}
if(this.accel&&this.accel.getValue){
step=this.accel.getValue(step);
}
var e=new dojo.animation.AnimationEvent(this,"animate",this.curve.getValue(step),this._startTime,curr,this._endTime,this.duration,this._percent,Math.round(fps));
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onAnimate=="function"){
this.onAnimate(e);
}
if(step<1){
this._timer=setTimeout(dojo.lang.hitch(this,"_cycle"),this.rate);
}else{
e.type="end";
this._active=false;
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onEnd=="function"){
this.onEnd(e);
}
if(this.repeatCount>0){
this.repeatCount--;
this.play(true);
}else{
if(this.repeatCount==-1){
this.play(true);
}else{
if(this._startRepeatCount){
this.repeatCount=this._startRepeatCount;
this._startRepeatCount=0;
}
if(this._animSequence){
this._animSequence._playNext();
}
}
}
}
}
}});
dojo.animation.AnimationEvent=function(anim,type,_366,_367,_368,_369,dur,pct,fps){
this.type=type;
this.animation=anim;
this.coords=_366;
this.x=_366[0];
this.y=_366[1];
this.z=_366[2];
this.startTime=_367;
this.currentTime=_368;
this.endTime=_369;
this.duration=dur;
this.percent=pct;
this.fps=fps;
};
dojo.lang.extend(dojo.animation.AnimationEvent,{coordsAsInts:function(){
var _36d=new Array(this.coords.length);
for(var i=0;i<this.coords.length;i++){
_36d[i]=Math.round(this.coords[i]);
}
return _36d;
}});
dojo.animation.AnimationSequence=function(_36f){
this._anims=[];
this.repeatCount=_36f||0;
};
dojo.lang.extend(dojo.animation.AnimationSequence,{repeateCount:0,_anims:[],_currAnim:-1,onBegin:null,onEnd:null,onNext:null,handler:null,add:function(){
for(var i=0;i<arguments.length;i++){
this._anims.push(arguments[i]);
arguments[i]._animSequence=this;
}
},remove:function(anim){
for(var i=0;i<this._anims.length;i++){
if(this._anims[i]==anim){
this._anims[i]._animSequence=null;
this._anims.splice(i,1);
break;
}
}
},removeAll:function(){
for(var i=0;i<this._anims.length;i++){
this._anims[i]._animSequence=null;
}
this._anims=[];
this._currAnim=-1;
},clear:function(){
this.removeAll();
},play:function(_374){
if(this._anims.length==0){
return;
}
if(_374||!this._anims[this._currAnim]){
this._currAnim=0;
}
if(this._anims[this._currAnim]){
if(this._currAnim==0){
var e={type:"begin",animation:this._anims[this._currAnim]};
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onBegin=="function"){
this.onBegin(e);
}
}
this._anims[this._currAnim].play(_374);
}
},pause:function(){
if(this._anims[this._currAnim]){
this._anims[this._currAnim].pause();
}
},playPause:function(){
if(this._anims.length==0){
return;
}
if(this._currAnim==-1){
this._currAnim=0;
}
if(this._anims[this._currAnim]){
this._anims[this._currAnim].playPause();
}
},stop:function(){
if(this._anims[this._currAnim]){
this._anims[this._currAnim].stop();
}
},status:function(){
if(this._anims[this._currAnim]){
return this._anims[this._currAnim].status();
}else{
return "stopped";
}
},_setCurrent:function(anim){
for(var i=0;i<this._anims.length;i++){
if(this._anims[i]==anim){
this._currAnim=i;
break;
}
}
},_playNext:function(){
if(this._currAnim==-1||this._anims.length==0){
return;
}
this._currAnim++;
if(this._anims[this._currAnim]){
var e={type:"next",animation:this._anims[this._currAnim]};
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onNext=="function"){
this.onNext(e);
}
this._anims[this._currAnim].play(true);
}else{
var e={type:"end",animation:this._anims[this._anims.length-1]};
if(typeof this.handler=="function"){
this.handler(e);
}
if(typeof this.onEnd=="function"){
this.onEnd(e);
}
if(this.repeatCount>0){
this._currAnim=0;
this.repeatCount--;
this._anims[this._currAnim].play(true);
}else{
if(this.repeatCount==-1){
this._currAnim=0;
this._anims[this._currAnim].play(true);
}else{
this._currAnim=-1;
}
}
}
}});
dojo.hostenv.conditionalLoadModule({common:["dojo.animation.Animation",false,false]});
dojo.hostenv.moduleLoaded("dojo.animation.*");
dojo.require("dojo.lang");
dojo.provide("dojo.event");
dojo.event=new function(){
this.canTimeout=dojo.lang.isFunction(dj_global["setTimeout"])||dojo.lang.isAlien(dj_global["setTimeout"]);
function interpolateArgs(args){
var dl=dojo.lang;
var ao={srcObj:dj_global,srcFunc:null,adviceObj:dj_global,adviceFunc:null,aroundObj:null,aroundFunc:null,adviceType:(args.length>2)?args[0]:"after",precedence:"last",once:false,delay:null,rate:0,adviceMsg:false};
switch(args.length){
case 0:
return;
case 1:
return;
case 2:
ao.srcFunc=args[0];
ao.adviceFunc=args[1];
break;
case 3:
if((dl.isObject(args[0]))&&(dl.isString(args[1]))&&(dl.isString(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
}else{
if((dl.isString(args[1]))&&(dl.isString(args[2]))){
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
}else{
if((dl.isObject(args[0]))&&(dl.isString(args[1]))&&(dl.isFunction(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
var _37c=dojo.lang.nameAnonFunc(args[2],ao.adviceObj);
ao.adviceFunc=_37c;
}else{
if((dl.isFunction(args[0]))&&(dl.isObject(args[1]))&&(dl.isString(args[2]))){
ao.adviceType="after";
ao.srcObj=dj_global;
var _37c=dojo.lang.nameAnonFunc(args[0],ao.srcObj);
ao.srcFunc=_37c;
ao.adviceObj=args[1];
ao.adviceFunc=args[2];
}
}
}
}
break;
case 4:
if((dl.isObject(args[0]))&&(dl.isObject(args[2]))){
ao.adviceType="after";
ao.srcObj=args[0];
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isString(args[1]))&&(dl.isObject(args[2]))){
ao.adviceType=args[0];
ao.srcObj=dj_global;
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if((dl.isString(args[0]))&&(dl.isFunction(args[1]))&&(dl.isObject(args[2]))){
ao.adviceType=args[0];
ao.srcObj=dj_global;
var _37c=dojo.lang.nameAnonFunc(args[1],dj_global);
ao.srcFunc=_37c;
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
if(dl.isObject(args[1])){
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=dj_global;
ao.adviceFunc=args[3];
}else{
if(dl.isObject(args[2])){
ao.srcObj=dj_global;
ao.srcFunc=args[1];
ao.adviceObj=args[2];
ao.adviceFunc=args[3];
}else{
ao.srcObj=ao.adviceObj=ao.aroundObj=dj_global;
ao.srcFunc=args[1];
ao.adviceFunc=args[2];
ao.aroundFunc=args[3];
}
}
}
}
}
break;
case 6:
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=args[3];
ao.adviceFunc=args[4];
ao.aroundFunc=args[5];
ao.aroundObj=dj_global;
break;
default:
ao.srcObj=args[1];
ao.srcFunc=args[2];
ao.adviceObj=args[3];
ao.adviceFunc=args[4];
ao.aroundObj=args[5];
ao.aroundFunc=args[6];
ao.once=args[7];
ao.delay=args[8];
ao.rate=args[9];
ao.adviceMsg=args[10];
break;
}
if((typeof ao.srcFunc).toLowerCase()!="string"){
ao.srcFunc=dojo.lang.getNameInObj(ao.srcObj,ao.srcFunc);
}
if((typeof ao.adviceFunc).toLowerCase()!="string"){
ao.adviceFunc=dojo.lang.getNameInObj(ao.adviceObj,ao.adviceFunc);
}
if((ao.aroundObj)&&((typeof ao.aroundFunc).toLowerCase()!="string")){
ao.aroundFunc=dojo.lang.getNameInObj(ao.aroundObj,ao.aroundFunc);
}
if(!ao.srcObj){
dojo.raise("bad srcObj for srcFunc: "+ao.srcFunc);
}
if(!ao.adviceObj){
dojo.raise("bad adviceObj for adviceFunc: "+ao.adviceFunc);
}
return ao;
}
this.connect=function(){
var ao=interpolateArgs(arguments);
var mjp=dojo.event.MethodJoinPoint.getForMethod(ao.srcObj,ao.srcFunc);
if(ao.adviceFunc){
var mjp2=dojo.event.MethodJoinPoint.getForMethod(ao.adviceObj,ao.adviceFunc);
}
mjp.kwAddAdvice(ao);
return mjp;
};
this.connectBefore=function(){
var args=["before"];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return this.connect.apply(this,args);
};
this.connectAround=function(){
var args=["around"];
for(var i=0;i<arguments.length;i++){
args.push(arguments[i]);
}
return this.connect.apply(this,args);
};
this._kwConnectImpl=function(_384,_385){
var fn=(_385)?"disconnect":"connect";
if(typeof _384["srcFunc"]=="function"){
_384.srcObj=_384["srcObj"]||dj_global;
var _387=dojo.lang.nameAnonFunc(_384.srcFunc,_384.srcObj);
_384.srcFunc=_387;
}
if(typeof _384["adviceFunc"]=="function"){
_384.adviceObj=_384["adviceObj"]||dj_global;
var _387=dojo.lang.nameAnonFunc(_384.adviceFunc,_384.adviceObj);
_384.adviceFunc=_387;
}
return dojo.event[fn]((_384["type"]||_384["adviceType"]||"after"),_384["srcObj"]||dj_global,_384["srcFunc"],_384["adviceObj"]||_384["targetObj"]||dj_global,_384["adviceFunc"]||_384["targetFunc"],_384["aroundObj"],_384["aroundFunc"],_384["once"],_384["delay"],_384["rate"],_384["adviceMsg"]||false);
};
this.kwConnect=function(_388){
return this._kwConnectImpl(_388,false);
};
this.disconnect=function(){
var ao=interpolateArgs(arguments);
if(!ao.adviceFunc){
return;
}
var mjp=dojo.event.MethodJoinPoint.getForMethod(ao.srcObj,ao.srcFunc);
return mjp.removeAdvice(ao.adviceObj,ao.adviceFunc,ao.adviceType,ao.once);
};
this.kwDisconnect=function(_38b){
return this._kwConnectImpl(_38b,true);
};
};
dojo.event.MethodInvocation=function(_38c,obj,args){
this.jp_=_38c;
this.object=obj;
this.args=[];
for(var x=0;x<args.length;x++){
this.args[x]=args[x];
}
this.around_index=-1;
};
dojo.event.MethodInvocation.prototype.proceed=function(){
this.around_index++;
if(this.around_index>=this.jp_.around.length){
return this.jp_.object[this.jp_.methodname].apply(this.jp_.object,this.args);
}else{
var ti=this.jp_.around[this.around_index];
var mobj=ti[0]||dj_global;
var meth=ti[1];
return mobj[meth].call(mobj,this);
}
};
dojo.event.MethodJoinPoint=function(obj,_394){
this.object=obj||dj_global;
this.methodname=_394;
this.methodfunc=this.object[_394];
this.before=[];
this.after=[];
this.around=[];
};
dojo.event.MethodJoinPoint.getForMethod=function(obj,_396){
if(!obj){
obj=dj_global;
}
if(!obj[_396]){
obj[_396]=function(){
};
}else{
if((!dojo.lang.isFunction(obj[_396]))&&(!dojo.lang.isAlien(obj[_396]))){
return null;
}
}
var _397=_396+"$joinpoint";
var _398=_396+"$joinpoint$method";
var _399=obj[_397];
if(!_399){
var _39a=false;
if(dojo.event["browser"]){
if((obj["attachEvent"])||(obj["nodeType"])||(obj["addEventListener"])){
_39a=true;
dojo.event.browser.addClobberNodeAttrs(obj,[_397,_398,_396]);
}
}
obj[_398]=obj[_396];
_399=obj[_397]=new dojo.event.MethodJoinPoint(obj,_398);
obj[_396]=function(){
var args=[];
if((_39a)&&(!arguments.length)&&(window.event)){
args.push(dojo.event.browser.fixEvent(window.event));
}else{
for(var x=0;x<arguments.length;x++){
if((x==0)&&(_39a)&&(dojo.event.browser.isEvent(arguments[x]))){
args.push(dojo.event.browser.fixEvent(arguments[x]));
}else{
args.push(arguments[x]);
}
}
}
return _399.run.apply(_399,args);
};
}
return _399;
};
dojo.lang.extend(dojo.event.MethodJoinPoint,{unintercept:function(){
this.object[this.methodname]=this.methodfunc;
},run:function(){
var obj=this.object||dj_global;
var args=arguments;
var _39f=[];
for(var x=0;x<args.length;x++){
_39f[x]=args[x];
}
var _3a1=function(marr){
if(!marr){
dojo.debug("Null argument to unrollAdvice()");
return;
}
var _3a3=marr[0]||dj_global;
var _3a4=marr[1];
if(!_3a3[_3a4]){
dojo.raise("function \""+_3a4+"\" does not exist on \""+_3a3+"\"");
}
var _3a5=marr[2]||dj_global;
var _3a6=marr[3];
var msg=marr[6];
var _3a8;
var to={args:[],jp_:this,object:obj,proceed:function(){
return _3a3[_3a4].apply(_3a3,to.args);
}};
to.args=_39f;
var _3aa=parseInt(marr[4]);
var _3ab=((!isNaN(_3aa))&&(marr[4]!==null)&&(typeof marr[4]!="undefined"));
if(marr[5]){
var rate=parseInt(marr[5]);
var cur=new Date();
var _3ae=false;
if((marr["last"])&&((cur-marr.last)<=rate)){
if(dojo.event.canTimeout){
if(marr["delayTimer"]){
clearTimeout(marr.delayTimer);
}
var tod=parseInt(rate*2);
var mcpy=dojo.lang.shallowCopy(marr);
marr.delayTimer=setTimeout(function(){
mcpy[5]=0;
_3a1(mcpy);
},tod);
}
return;
}else{
marr.last=cur;
}
}
if(_3a6){
_3a5[_3a6].call(_3a5,to);
}else{
if((_3ab)&&((dojo.render.html)||(dojo.render.svg))){
dj_global["setTimeout"](function(){
if(msg){
_3a3[_3a4].call(_3a3,to);
}else{
_3a3[_3a4].apply(_3a3,args);
}
},_3aa);
}else{
if(msg){
_3a3[_3a4].call(_3a3,to);
}else{
_3a3[_3a4].apply(_3a3,args);
}
}
}
};
if(this.before.length>0){
dojo.lang.forEach(this.before,_3a1,true);
}
var _3b1;
if(this.around.length>0){
var mi=new dojo.event.MethodInvocation(this,obj,args);
_3b1=mi.proceed();
}else{
if(this.methodfunc){
_3b1=this.object[this.methodname].apply(this.object,args);
}
}
if(this.after.length>0){
dojo.lang.forEach(this.after,_3a1,true);
}
return (this.methodfunc)?_3b1:null;
},getArr:function(kind){
var arr=this.after;
if((typeof kind=="string")&&(kind.indexOf("before")!=-1)){
arr=this.before;
}else{
if(kind=="around"){
arr=this.around;
}
}
return arr;
},kwAddAdvice:function(args){
this.addAdvice(args["adviceObj"],args["adviceFunc"],args["aroundObj"],args["aroundFunc"],args["adviceType"],args["precedence"],args["once"],args["delay"],args["rate"],args["adviceMsg"]);
},addAdvice:function(_3b6,_3b7,_3b8,_3b9,_3ba,_3bb,once,_3bd,rate,_3bf){
var arr=this.getArr(_3ba);
if(!arr){
dojo.raise("bad this: "+this);
}
var ao=[_3b6,_3b7,_3b8,_3b9,_3bd,rate,_3bf];
if(once){
if(this.hasAdvice(_3b6,_3b7,_3ba,arr)>=0){
return;
}
}
if(_3bb=="first"){
arr.unshift(ao);
}else{
arr.push(ao);
}
},hasAdvice:function(_3c2,_3c3,_3c4,arr){
if(!arr){
arr=this.getArr(_3c4);
}
var ind=-1;
for(var x=0;x<arr.length;x++){
if((arr[x][0]==_3c2)&&(arr[x][1]==_3c3)){
ind=x;
}
}
return ind;
},removeAdvice:function(_3c8,_3c9,_3ca,once){
var arr=this.getArr(_3ca);
var ind=this.hasAdvice(_3c8,_3c9,_3ca,arr);
if(ind==-1){
return false;
}
while(ind!=-1){
arr.splice(ind,1);
if(once){
break;
}
ind=this.hasAdvice(_3c8,_3c9,_3ca,arr);
}
return true;
}});
dojo.require("dojo.event");
dojo.provide("dojo.event.topic");
dojo.event.topic=new function(){
this.topics={};
this.getTopic=function(_3ce){
if(!this.topics[_3ce]){
this.topics[_3ce]=new this.TopicImpl(_3ce);
}
return this.topics[_3ce];
};
this.registerPublisher=function(_3cf,obj,_3d1){
var _3cf=this.getTopic(_3cf);
_3cf.registerPublisher(obj,_3d1);
};
this.subscribe=function(_3d2,obj,_3d4){
var _3d2=this.getTopic(_3d2);
_3d2.subscribe(obj,_3d4);
};
this.unsubscribe=function(_3d5,obj,_3d7){
var _3d5=this.getTopic(_3d5);
_3d5.unsubscribe(obj,_3d7);
};
this.publish=function(_3d8,_3d9){
var _3d8=this.getTopic(_3d8);
var args=[];
if((arguments.length==2)&&(_3d9.length)&&(typeof _3d9!="string")){
args=_3d9;
}else{
var args=[];
for(var x=1;x<arguments.length;x++){
args.push(arguments[x]);
}
}
_3d8.sendMessage.apply(_3d8,args);
};
};
dojo.event.topic.TopicImpl=function(_3dc){
this.topicName=_3dc;
var self=this;
self.subscribe=function(_3de,_3df){
var tf=_3df||_3de;
var to=(!_3df)?dj_global:_3de;
dojo.event.kwConnect({srcObj:self,srcFunc:"sendMessage",adviceObj:to,adviceFunc:tf});
};
self.unsubscribe=function(_3e2,_3e3){
var tf=(!_3e3)?_3e2:_3e3;
var to=(!_3e3)?null:_3e2;
dojo.event.kwDisconnect({srcObj:self,srcFunc:"sendMessage",adviceObj:to,adviceFunc:tf});
};
self.registerPublisher=function(_3e6,_3e7){
dojo.event.connect(_3e6,_3e7,self,"sendMessage");
};
self.sendMessage=function(_3e8){
};
};
dojo.provide("dojo.event.browser");
dojo.require("dojo.event");
dojo_ie_clobber=new function(){
this.clobberNodes=[];
function nukeProp(node,prop){
try{
node[prop]=null;
}
catch(e){
}
try{
delete node[prop];
}
catch(e){
}
try{
node.removeAttribute(prop);
}
catch(e){
}
}
this.clobber=function(_3eb){
var na;
var tna;
if(_3eb){
tna=_3eb.getElementsByTagName("*");
na=[_3eb];
for(var x=0;x<tna.length;x++){
if(tna[x]["__doClobber__"]){
na.push(tna[x]);
}
}
}else{
try{
window.onload=null;
}
catch(e){
}
na=(this.clobberNodes.length)?this.clobberNodes:document.all;
}
tna=null;
var _3ef={};
for(var i=na.length-1;i>=0;i=i-1){
var el=na[i];
if(el["__clobberAttrs__"]){
for(var j=0;j<el.__clobberAttrs__.length;j++){
nukeProp(el,el.__clobberAttrs__[j]);
}
nukeProp(el,"__clobberAttrs__");
nukeProp(el,"__doClobber__");
}
}
na=null;
};
};
if(dojo.render.html.ie){
window.onunload=function(){
dojo_ie_clobber.clobber();
try{
if((dojo["widget"])&&(dojo.widget["manager"])){
dojo.widget.manager.destroyAll();
}
}
catch(e){
}
try{
window.onload=null;
}
catch(e){
}
try{
window.onunload=null;
}
catch(e){
}
dojo_ie_clobber.clobberNodes=[];
};
}
dojo.event.browser=new function(){
var _3f3=0;
this.clean=function(node){
if(dojo.render.html.ie){
dojo_ie_clobber.clobber(node);
}
};
this.addClobberNode=function(node){
if(!node["__doClobber__"]){
node.__doClobber__=true;
dojo_ie_clobber.clobberNodes.push(node);
node.__clobberAttrs__=[];
}
};
this.addClobberNodeAttrs=function(node,_3f7){
this.addClobberNode(node);
for(var x=0;x<_3f7.length;x++){
node.__clobberAttrs__.push(_3f7[x]);
}
};
this.removeListener=function(node,_3fa,fp,_3fc){
if(!_3fc){
var _3fc=false;
}
_3fa=_3fa.toLowerCase();
if(_3fa.substr(0,2)=="on"){
_3fa=_3fa.substr(2);
}
if(node.removeEventListener){
node.removeEventListener(_3fa,fp,_3fc);
}
};
this.addListener=function(node,_3fe,fp,_400,_401){
if(!node){
return;
}
if(!_400){
var _400=false;
}
_3fe=_3fe.toLowerCase();
if(_3fe.substr(0,2)!="on"){
_3fe="on"+_3fe;
}
if(!_401){
var _402=function(evt){
if(!evt){
evt=window.event;
}
var ret=fp(dojo.event.browser.fixEvent(evt));
if(_400){
dojo.event.browser.stopEvent(evt);
}
return ret;
};
}else{
_402=fp;
}
if(node.addEventListener){
node.addEventListener(_3fe.substr(2),_402,_400);
return _402;
}else{
if(typeof node[_3fe]=="function"){
var _405=node[_3fe];
node[_3fe]=function(e){
_405(e);
return _402(e);
};
}else{
node[_3fe]=_402;
}
if(dojo.render.html.ie){
this.addClobberNodeAttrs(node,[_3fe]);
}
return _402;
}
};
this.isEvent=function(obj){
return (typeof obj!="undefined")&&(typeof Event!="undefined")&&(obj.eventPhase);
};
this.currentEvent=null;
this.callListener=function(_408,_409){
if(typeof _408!="function"){
dojo.raise("listener not a function: "+_408);
}
dojo.event.browser.currentEvent.currentTarget=_409;
return _408.call(_409,dojo.event.browser.currentEvent);
};
this.stopPropagation=function(){
dojo.event.browser.currentEvent.cancelBubble=true;
};
this.preventDefault=function(){
dojo.event.browser.currentEvent.returnValue=false;
};
this.keys={KEY_BACKSPACE:8,KEY_TAB:9,KEY_ENTER:13,KEY_SHIFT:16,KEY_CTRL:17,KEY_ALT:18,KEY_PAUSE:19,KEY_CAPS_LOCK:20,KEY_ESCAPE:27,KEY_SPACE:32,KEY_PAGE_UP:33,KEY_PAGE_DOWN:34,KEY_END:35,KEY_HOME:36,KEY_LEFT_ARROW:37,KEY_UP_ARROW:38,KEY_RIGHT_ARROW:39,KEY_DOWN_ARROW:40,KEY_INSERT:45,KEY_DELETE:46,KEY_LEFT_WINDOW:91,KEY_RIGHT_WINDOW:92,KEY_SELECT:93,KEY_F1:112,KEY_F2:113,KEY_F3:114,KEY_F4:115,KEY_F5:116,KEY_F6:117,KEY_F7:118,KEY_F8:119,KEY_F9:120,KEY_F10:121,KEY_F11:122,KEY_F12:123,KEY_NUM_LOCK:144,KEY_SCROLL_LOCK:145};
this.revKeys=[];
for(var key in this.keys){
this.revKeys[this.keys[key]]=key;
}
this.fixEvent=function(evt){
if((!evt)&&(window["event"])){
var evt=window.event;
}
if((evt["type"])&&(evt["type"].indexOf("key")==0)){
evt.keys=this.revKeys;
for(var key in this.keys){
evt[key]=this.keys[key];
}
if((dojo.render.html.ie)&&(evt["type"]=="keypress")){
evt.charCode=evt.keyCode;
}
}
if(dojo.render.html.ie){
if(!evt.target){
evt.target=evt.srcElement;
}
if(!evt.currentTarget){
evt.currentTarget=evt.srcElement;
}
if(!evt.layerX){
evt.layerX=evt.offsetX;
}
if(!evt.layerY){
evt.layerY=evt.offsetY;
}
if(evt.fromElement){
evt.relatedTarget=evt.fromElement;
}
if(evt.toElement){
evt.relatedTarget=evt.toElement;
}
this.currentEvent=evt;
evt.callListener=this.callListener;
evt.stopPropagation=this.stopPropagation;
evt.preventDefault=this.preventDefault;
}
return evt;
};
this.stopEvent=function(ev){
if(window.event){
ev.returnValue=false;
ev.cancelBubble=true;
}else{
ev.preventDefault();
ev.stopPropagation();
}
};
};
dojo.hostenv.conditionalLoadModule({common:["dojo.event","dojo.event.topic"],browser:["dojo.event.browser"]});
dojo.hostenv.moduleLoaded("dojo.event.*");
dojo.provide("dojo.fx.html");
dojo.require("dojo.html");
dojo.require("dojo.style");
dojo.require("dojo.lang");
dojo.require("dojo.animation.*");
dojo.require("dojo.event.*");
dojo.require("dojo.graphics.color");
dojo.fx.duration=500;
dojo.fx.html._makeFadeable=function(node){
if(dojo.render.html.ie){
if((node.style.zoom.length==0)&&(dojo.style.getStyle(node,"zoom")=="normal")){
node.style.zoom="1";
}
if((node.style.width.length==0)&&(dojo.style.getStyle(node,"width")=="auto")){
node.style.width="auto";
}
}
};
dojo.fx.html.fadeOut=function(node,_410,_411,_412){
return dojo.fx.html.fade(node,_410,dojo.style.getOpacity(node),0,_411,_412);
};
dojo.fx.html.fadeIn=function(node,_414,_415,_416){
return dojo.fx.html.fade(node,_414,dojo.style.getOpacity(node),1,_415,_416);
};
dojo.fx.html.fadeHide=function(node,_418,_419,_41a){
node=dojo.byId(node);
if(!_418){
_418=150;
}
return dojo.fx.html.fadeOut(node,_418,function(node){
node.style.display="none";
if(typeof _419=="function"){
_419(node);
}
});
};
dojo.fx.html.fadeShow=function(node,_41d,_41e,_41f){
node=dojo.byId(node);
if(!_41d){
_41d=150;
}
node.style.display="block";
return dojo.fx.html.fade(node,_41d,0,1,_41e,_41f);
};
dojo.fx.html.fade=function(node,_421,_422,_423,_424,_425){
node=dojo.byId(node);
dojo.fx.html._makeFadeable(node);
var anim=new dojo.animation.Animation(new dojo.math.curves.Line([_422],[_423]),_421||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
dojo.style.setOpacity(node,e.x);
});
if(_424){
dojo.event.connect(anim,"onEnd",function(e){
_424(node,anim);
});
}
if(!_425){
anim.play(true);
}
return anim;
};
dojo.fx.html.slideTo=function(node,_42a,_42b,_42c,_42d){
if(!dojo.lang.isNumber(_42a)){
var tmp=_42a;
_42a=_42b;
_42b=tmp;
}
node=dojo.byId(node);
var top=node.offsetTop;
var left=node.offsetLeft;
var pos=dojo.style.getComputedStyle(node,"position");
if(pos=="relative"||pos=="static"){
top=parseInt(dojo.style.getComputedStyle(node,"top"))||0;
left=parseInt(dojo.style.getComputedStyle(node,"left"))||0;
}
return dojo.fx.html.slide(node,_42a,[left,top],_42b,_42c,_42d);
};
dojo.fx.html.slideBy=function(node,_433,_434,_435,_436){
if(!dojo.lang.isNumber(_433)){
var tmp=_433;
_433=_434;
_434=tmp;
}
node=dojo.byId(node);
var top=node.offsetTop;
var left=node.offsetLeft;
var pos=dojo.style.getComputedStyle(node,"position");
if(pos=="relative"||pos=="static"){
top=parseInt(dojo.style.getComputedStyle(node,"top"))||0;
left=parseInt(dojo.style.getComputedStyle(node,"left"))||0;
}
return dojo.fx.html.slideTo(node,_433,[left+_434[0],top+_434[1]],_435,_436);
};
dojo.fx.html.slide=function(node,_43c,_43d,_43e,_43f,_440){
if(!dojo.lang.isNumber(_43c)){
var tmp=_43c;
_43c=_43e;
_43e=_43d;
_43d=tmp;
}
node=dojo.byId(node);
if(dojo.style.getComputedStyle(node,"position")=="static"){
node.style.position="relative";
}
var anim=new dojo.animation.Animation(new dojo.math.curves.Line(_43d,_43e),_43c||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
with(node.style){
left=e.x+"px";
top=e.y+"px";
}
});
if(_43f){
dojo.event.connect(anim,"onEnd",function(e){
_43f(node,anim);
});
}
if(!_440){
anim.play(true);
}
return anim;
};
dojo.fx.html.colorFadeIn=function(node,_446,_447,_448,_449,_44a){
if(!dojo.lang.isNumber(_446)){
var tmp=_446;
_446=_447;
_447=tmp;
}
node=dojo.byId(node);
var _44c=dojo.html.getBackgroundColor(node);
var bg=dojo.style.getStyle(node,"background-color").toLowerCase();
var _44e=bg=="transparent"||bg=="rgba(0, 0, 0, 0)";
while(_44c.length>3){
_44c.pop();
}
var rgb=new dojo.graphics.color.Color(_447).toRgb();
var anim=dojo.fx.html.colorFade(node,_446||dojo.fx.duration,_447,_44c,_449,true);
dojo.event.connect(anim,"onEnd",function(e){
if(_44e){
node.style.backgroundColor="transparent";
}
});
if(_448>0){
node.style.backgroundColor="rgb("+rgb.join(",")+")";
if(!_44a){
setTimeout(function(){
anim.play(true);
},_448);
}
}else{
if(!_44a){
anim.play(true);
}
}
return anim;
};
dojo.fx.html.highlight=dojo.fx.html.colorFadeIn;
dojo.fx.html.colorFadeFrom=dojo.fx.html.colorFadeIn;
dojo.fx.html.colorFadeOut=function(node,_453,_454,_455,_456,_457){
if(!dojo.lang.isNumber(_453)){
var tmp=_453;
_453=_454;
_454=tmp;
}
node=dojo.byId(node);
var _459=new dojo.graphics.color.Color(dojo.html.getBackgroundColor(node)).toRgb();
var rgb=new dojo.graphics.color.Color(_454).toRgb();
var anim=dojo.fx.html.colorFade(node,_453||dojo.fx.duration,_459,rgb,_456,_455>0||_457);
if(_455>0){
node.style.backgroundColor="rgb("+_459.join(",")+")";
if(!_457){
setTimeout(function(){
anim.play(true);
},_455);
}
}
return anim;
};
dojo.fx.html.unhighlight=dojo.fx.html.colorFadeOut;
dojo.fx.html.colorFadeTo=dojo.fx.html.colorFadeOut;
dojo.fx.html.colorFade=function(node,_45d,_45e,_45f,_460,_461){
if(!dojo.lang.isNumber(_45d)){
var tmp=_45d;
_45d=_45f;
_45f=_45e;
_45e=tmp;
}
node=dojo.byId(node);
var _463=new dojo.graphics.color.Color(_45e).toRgb();
var _464=new dojo.graphics.color.Color(_45f).toRgb();
var anim=new dojo.animation.Animation(new dojo.math.curves.Line(_463,_464),_45d||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
node.style.backgroundColor="rgb("+e.coordsAsInts().join(",")+")";
});
if(_460){
dojo.event.connect(anim,"onEnd",function(e){
_460(node,anim);
});
}
if(!_461){
anim.play(true);
}
return anim;
};
dojo.fx.html.wipeShow=function(node,_469,_46a,_46b){
node=dojo.byId(node);
var _46c=dojo.html.getStyle(node,"overflow");
node.style.overflow="hidden";
node.style.height=0;
dojo.html.show(node);
var anim=new dojo.animation.Animation([[0],[node.scrollHeight]],_469||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
node.style.height=e.x+"px";
});
dojo.event.connect(anim,"onEnd",function(){
node.style.overflow=_46c;
node.style.height="auto";
if(_46a){
_46a(node,anim);
}
});
if(!_46b){
anim.play();
}
return anim;
};
dojo.fx.html.wipeHide=function(node,_470,_471,_472){
node=dojo.byId(node);
var _473=dojo.html.getStyle(node,"overflow");
node.style.overflow="hidden";
var anim=new dojo.animation.Animation([[node.offsetHeight],[0]],_470||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
node.style.height=e.x+"px";
});
dojo.event.connect(anim,"onEnd",function(){
node.style.overflow=_473;
dojo.html.hide(node);
if(_471){
_471(node,anim);
}
});
if(!_472){
anim.play();
}
return anim;
};
dojo.fx.html.wiper=function(node,_477){
this.node=dojo.byId(node);
if(_477){
dojo.event.connect(dojo.byId(_477),"onclick",this,"toggle");
}
};
dojo.lang.extend(dojo.fx.html.wiper,{duration:dojo.fx.duration,_anim:null,toggle:function(){
if(!this._anim){
var type="wipe"+(dojo.html.isVisible(this.node)?"Hide":"Show");
this._anim=dojo.fx[type](this.node,this.duration,dojo.lang.hitch(this,"_callback"));
}
},_callback:function(){
this._anim=null;
}});
dojo.fx.html.wipeIn=function(node,_47a,_47b,_47c){
node=dojo.byId(node);
var _47d=dojo.html.getStyle(node,"height");
dojo.html.show(node);
var _47e=node.offsetHeight;
var anim=dojo.fx.html.wipeInToHeight(node,_47a,_47e,function(e){
node.style.height=_47d||"auto";
if(_47b){
_47b(node,anim);
}
},_47c);
};
dojo.fx.html.wipeInToHeight=function(node,_482,_483,_484,_485){
node=dojo.byId(node);
var _486=dojo.html.getStyle(node,"overflow");
node.style.height="0px";
node.style.display="none";
if(_486=="visible"){
node.style.overflow="hidden";
}
var _487=dojo.lang.inArray(node.tagName.toLowerCase(),["tr","td","th"])?"":"block";
node.style.display=_487;
var anim=new dojo.animation.Animation(new dojo.math.curves.Line([0],[_483]),_482||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
node.style.height=Math.round(e.x)+"px";
});
dojo.event.connect(anim,"onEnd",function(e){
if(_486!="visible"){
node.style.overflow=_486;
}
if(_484){
_484(node,anim);
}
});
if(!_485){
anim.play(true);
}
return anim;
};
dojo.fx.html.wipeOut=function(node,_48c,_48d,_48e){
node=dojo.byId(node);
var _48f=dojo.html.getStyle(node,"overflow");
var _490=dojo.html.getStyle(node,"height");
var _491=node.offsetHeight;
node.style.overflow="hidden";
var anim=new dojo.animation.Animation(new dojo.math.curves.Line([_491],[0]),_48c||dojo.fx.duration,0);
dojo.event.connect(anim,"onAnimate",function(e){
node.style.height=Math.round(e.x)+"px";
});
dojo.event.connect(anim,"onEnd",function(e){
node.style.display="none";
node.style.overflow=_48f;
node.style.height=_490||"auto";
if(_48d){
_48d(node,anim);
}
});
if(!_48e){
anim.play(true);
}
return anim;
};
dojo.fx.html.explode=function(_495,_496,_497,_498,_499){
var _49a=dojo.html.toCoordinateArray(_495);
var _49b=document.createElement("div");
with(_49b.style){
position="absolute";
border="1px solid black";
display="none";
}
dojo.html.body().appendChild(_49b);
_496=dojo.byId(_496);
with(_496.style){
visibility="hidden";
display="block";
}
var _49c=dojo.html.toCoordinateArray(_496);
with(_496.style){
display="none";
visibility="visible";
}
var anim=new dojo.animation.Animation(new dojo.math.curves.Line(_49a,_49c),_497||dojo.fx.duration,0);
dojo.event.connect(anim,"onBegin",function(e){
_49b.style.display="block";
});
dojo.event.connect(anim,"onAnimate",function(e){
with(_49b.style){
left=e.x+"px";
top=e.y+"px";
width=e.coords[2]+"px";
height=e.coords[3]+"px";
}
});
dojo.event.connect(anim,"onEnd",function(){
_496.style.display="block";
_49b.parentNode.removeChild(_49b);
if(_498){
_498(_496,anim);
}
});
if(!_499){
anim.play();
}
return anim;
};
dojo.fx.html.implode=function(_4a0,end,_4a2,_4a3,_4a4){
var _4a5=dojo.html.toCoordinateArray(_4a0);
var _4a6=dojo.html.toCoordinateArray(end);
_4a0=dojo.byId(_4a0);
var _4a7=document.createElement("div");
with(_4a7.style){
position="absolute";
border="1px solid black";
display="none";
}
dojo.html.body().appendChild(_4a7);
var anim=new dojo.animation.Animation(new dojo.math.curves.Line(_4a5,_4a6),_4a2||dojo.fx.duration,0);
dojo.event.connect(anim,"onBegin",function(e){
_4a0.style.display="none";
_4a7.style.display="block";
});
dojo.event.connect(anim,"onAnimate",function(e){
with(_4a7.style){
left=e.x+"px";
top=e.y+"px";
width=e.coords[2]+"px";
height=e.coords[3]+"px";
}
});
dojo.event.connect(anim,"onEnd",function(){
_4a7.parentNode.removeChild(_4a7);
if(_4a3){
_4a3(_4a0,anim);
}
});
if(!_4a4){
anim.play();
}
return anim;
};
dojo.fx.html.Exploder=function(_4ab,_4ac){
_4ab=dojo.byId(_4ab);
_4ac=dojo.byId(_4ac);
var _4ad=this;
this.waitToHide=500;
this.timeToShow=100;
this.waitToShow=200;
this.timeToHide=70;
this.autoShow=false;
this.autoHide=false;
var _4ae=null;
var _4af=null;
var _4b0=null;
var _4b1=null;
var _4b2=null;
var _4b3=null;
this.showing=false;
this.onBeforeExplode=null;
this.onAfterExplode=null;
this.onBeforeImplode=null;
this.onAfterImplode=null;
this.onExploding=null;
this.onImploding=null;
this.timeShow=function(){
clearTimeout(_4b0);
_4b0=setTimeout(_4ad.show,_4ad.waitToShow);
};
this.show=function(){
clearTimeout(_4b0);
clearTimeout(_4b1);
if((_4af&&_4af.status()=="playing")||(_4ae&&_4ae.status()=="playing")||_4ad.showing){
return;
}
if(typeof _4ad.onBeforeExplode=="function"){
_4ad.onBeforeExplode(_4ab,_4ac);
}
_4ae=dojo.fx.html.explode(_4ab,_4ac,_4ad.timeToShow,function(e){
_4ad.showing=true;
if(typeof _4ad.onAfterExplode=="function"){
_4ad.onAfterExplode(_4ab,_4ac);
}
});
if(typeof _4ad.onExploding=="function"){
dojo.event.connect(_4ae,"onAnimate",this,"onExploding");
}
};
this.timeHide=function(){
clearTimeout(_4b0);
clearTimeout(_4b1);
if(_4ad.showing){
_4b1=setTimeout(_4ad.hide,_4ad.waitToHide);
}
};
this.hide=function(){
clearTimeout(_4b0);
clearTimeout(_4b1);
if(_4ae&&_4ae.status()=="playing"){
return;
}
_4ad.showing=false;
if(typeof _4ad.onBeforeImplode=="function"){
_4ad.onBeforeImplode(_4ab,_4ac);
}
_4af=dojo.fx.html.implode(_4ac,_4ab,_4ad.timeToHide,function(e){
if(typeof _4ad.onAfterImplode=="function"){
_4ad.onAfterImplode(_4ab,_4ac);
}
});
if(typeof _4ad.onImploding=="function"){
dojo.event.connect(_4af,"onAnimate",this,"onImploding");
}
};
dojo.event.connect(_4ab,"onclick",function(e){
if(_4ad.showing){
_4ad.hide();
}else{
_4ad.show();
}
});
dojo.event.connect(_4ab,"onmouseover",function(e){
if(_4ad.autoShow){
_4ad.timeShow();
}
});
dojo.event.connect(_4ab,"onmouseout",function(e){
if(_4ad.autoHide){
_4ad.timeHide();
}
});
dojo.event.connect(_4ac,"onmouseover",function(e){
clearTimeout(_4b1);
});
dojo.event.connect(_4ac,"onmouseout",function(e){
if(_4ad.autoHide){
_4ad.timeHide();
}
});
dojo.event.connect(document.documentElement||dojo.html.body(),"onclick",function(e){
if(_4ad.autoHide&&_4ad.showing&&!dojo.dom.isDescendantOf(e.target,_4ac)&&!dojo.dom.isDescendantOf(e.target,_4ab)){
_4ad.hide();
}
});
return this;
};
dojo.lang.mixin(dojo.fx,dojo.fx.html);
dojo.hostenv.conditionalLoadModule({browser:["dojo.fx.html"]});
dojo.hostenv.moduleLoaded("dojo.fx.*");
dojo.provide("dojo.logging.Logger");
dojo.provide("dojo.log");
dojo.require("dojo.lang");
dojo.logging.Record=function(lvl,msg){
this.level=lvl;
this.message=msg;
this.time=new Date();
};
dojo.logging.LogFilter=function(_4be){
this.passChain=_4be||"";
this.filter=function(_4bf){
return true;
};
};
dojo.logging.Logger=function(){
this.cutOffLevel=0;
this.propagate=true;
this.parent=null;
this.data=[];
this.filters=[];
this.handlers=[];
};
dojo.lang.extend(dojo.logging.Logger,{argsToArr:function(args){
var ret=[];
for(var x=0;x<args.length;x++){
ret.push(args[x]);
}
return ret;
},setLevel:function(lvl){
this.cutOffLevel=parseInt(lvl);
},isEnabledFor:function(lvl){
return parseInt(lvl)>=this.cutOffLevel;
},getEffectiveLevel:function(){
if((this.cutOffLevel==0)&&(this.parent)){
return this.parent.getEffectiveLevel();
}
return this.cutOffLevel;
},addFilter:function(flt){
this.filters.push(flt);
return this.filters.length-1;
},removeFilterByIndex:function(_4c6){
if(this.filters[_4c6]){
delete this.filters[_4c6];
return true;
}
return false;
},removeFilter:function(_4c7){
for(var x=0;x<this.filters.length;x++){
if(this.filters[x]===_4c7){
delete this.filters[x];
return true;
}
}
return false;
},removeAllFilters:function(){
this.filters=[];
},filter:function(rec){
for(var x=0;x<this.filters.length;x++){
if((this.filters[x]["filter"])&&(!this.filters[x].filter(rec))||(rec.level<this.cutOffLevel)){
return false;
}
}
return true;
},addHandler:function(hdlr){
this.handlers.push(hdlr);
return this.handlers.length-1;
},handle:function(rec){
if((!this.filter(rec))||(rec.level<this.cutOffLevel)){
return false;
}
for(var x=0;x<this.handlers.length;x++){
if(this.handlers[x]["handle"]){
this.handlers[x].handle(rec);
}
}
return true;
},log:function(lvl,msg){
if((this.propagate)&&(this.parent)&&(this.parent.rec.level>=this.cutOffLevel)){
this.parent.log(lvl,msg);
return false;
}
this.handle(new dojo.logging.Record(lvl,msg));
return true;
},debug:function(msg){
return this.logType("DEBUG",this.argsToArr(arguments));
},info:function(msg){
return this.logType("INFO",this.argsToArr(arguments));
},warning:function(msg){
return this.logType("WARNING",this.argsToArr(arguments));
},error:function(msg){
return this.logType("ERROR",this.argsToArr(arguments));
},critical:function(msg){
return this.logType("CRITICAL",this.argsToArr(arguments));
},exception:function(msg,e,_4d7){
if(e){
var _4d8=[e.name,(e.description||e.message)];
if(e.fileName){
_4d8.push(e.fileName);
_4d8.push("line "+e.lineNumber);
}
msg+=" "+_4d8.join(" : ");
}
this.logType("ERROR",msg);
if(!_4d7){
throw e;
}
},logType:function(type,args){
var na=[dojo.logging.log.getLevel(type)];
if(typeof args=="array"){
na=na.concat(args);
}else{
if((typeof args=="object")&&(args["length"])){
na=na.concat(this.argsToArr(args));
}else{
na=na.concat(this.argsToArr(arguments).slice(1));
}
}
return this.log.apply(this,na);
}});
void (function(){
var _4dc=dojo.logging.Logger.prototype;
_4dc.warn=_4dc.warning;
_4dc.err=_4dc.error;
_4dc.crit=_4dc.critical;
})();
dojo.logging.LogHandler=function(_4dd){
this.cutOffLevel=(_4dd)?_4dd:0;
this.formatter=null;
this.data=[];
this.filters=[];
};
dojo.logging.LogHandler.prototype.setFormatter=function(fmtr){
dj_unimplemented("setFormatter");
};
dojo.logging.LogHandler.prototype.flush=function(){
dj_unimplemented("flush");
};
dojo.logging.LogHandler.prototype.close=function(){
dj_unimplemented("close");
};
dojo.logging.LogHandler.prototype.handleError=function(){
dj_unimplemented("handleError");
};
dojo.logging.LogHandler.prototype.handle=function(_4df){
if((this.filter(_4df))&&(_4df.level>=this.cutOffLevel)){
this.emit(_4df);
}
};
dojo.logging.LogHandler.prototype.emit=function(_4e0){
dj_unimplemented("emit");
};
void (function(){
var _4e1=["setLevel","addFilter","removeFilterByIndex","removeFilter","removeAllFilters","filter"];
var tgt=dojo.logging.LogHandler.prototype;
var src=dojo.logging.Logger.prototype;
for(var x=0;x<_4e1.length;x++){
tgt[_4e1[x]]=src[_4e1[x]];
}
})();
dojo.logging.log=new dojo.logging.Logger();
dojo.logging.log.levels=[{"name":"DEBUG","level":1},{"name":"INFO","level":2},{"name":"WARNING","level":3},{"name":"ERROR","level":4},{"name":"CRITICAL","level":5}];
dojo.logging.log.loggers={};
dojo.logging.log.getLogger=function(name){
if(!this.loggers[name]){
this.loggers[name]=new dojo.logging.Logger();
this.loggers[name].parent=this;
}
return this.loggers[name];
};
dojo.logging.log.getLevelName=function(lvl){
for(var x=0;x<this.levels.length;x++){
if(this.levels[x].level==lvl){
return this.levels[x].name;
}
}
return null;
};
dojo.logging.log.addLevelName=function(name,lvl){
if(this.getLevelName(name)){
this.err("could not add log level "+name+" because a level with that name already exists");
return false;
}
this.levels.append({"name":name,"level":parseInt(lvl)});
return true;
};
dojo.logging.log.getLevel=function(name){
for(var x=0;x<this.levels.length;x++){
if(this.levels[x].name.toUpperCase()==name.toUpperCase()){
return this.levels[x].level;
}
}
return null;
};
dojo.logging.MemoryLogHandler=function(_4ec,_4ed,_4ee,_4ef){
dojo.logging.LogHandler.call(this,_4ec);
this.numRecords=(typeof djConfig["loggingNumRecords"]!="undefined")?djConfig["loggingNumRecords"]:((_4ed)?_4ed:-1);
this.postType=(typeof djConfig["loggingPostType"]!="undefined")?djConfig["loggingPostType"]:(_4ee||-1);
this.postInterval=(typeof djConfig["loggingPostInterval"]!="undefined")?djConfig["loggingPostInterval"]:(_4ee||-1);
};
dojo.logging.MemoryLogHandler.prototype=new dojo.logging.LogHandler();
dojo.logging.MemoryLogHandler.prototype.emit=function(_4f0){
this.data.push(_4f0);
if(this.numRecords!=-1){
while(this.data.length>this.numRecords){
this.data.shift();
}
}
};
dojo.logging.logQueueHandler=new dojo.logging.MemoryLogHandler(0,50,0,10000);
dojo.logging.logQueueHandler.emit=function(_4f1){
var _4f2=String(dojo.log.getLevelName(_4f1.level)+": "+_4f1.time.toLocaleTimeString())+": "+_4f1.message;
if(!dj_undef("debug",dj_global)){
dojo.debug(_4f2);
}else{
if((typeof dj_global["print"]=="function")&&(!dojo.render.html.capable)){
print(_4f2);
}
}
this.data.push(_4f1);
if(this.numRecords!=-1){
while(this.data.length>this.numRecords){
this.data.shift();
}
}
};
dojo.logging.log.addHandler(dojo.logging.logQueueHandler);
dojo.log=dojo.logging.log;
dojo.hostenv.conditionalLoadModule({common:["dojo.logging.Logger",false,false],rhino:["dojo.logging.RhinoLogger"]});
dojo.hostenv.moduleLoaded("dojo.logging.*");
dojo.provide("dojo.io.IO");
dojo.require("dojo.string");
dojo.io.transports=[];
dojo.io.hdlrFuncNames=["load","error"];
dojo.io.Request=function(url,_4f4,_4f5,_4f6){
if((arguments.length==1)&&(arguments[0].constructor==Object)){
this.fromKwArgs(arguments[0]);
}else{
this.url=url;
if(_4f4){
this.mimetype=_4f4;
}
if(_4f5){
this.transport=_4f5;
}
if(arguments.length>=4){
this.changeUrl=_4f6;
}
}
};
dojo.lang.extend(dojo.io.Request,{url:"",mimetype:"text/plain",method:"GET",content:undefined,transport:undefined,changeUrl:undefined,formNode:undefined,sync:false,bindSuccess:false,useCache:false,preventCache:false,load:function(type,data,evt){
},error:function(type,_4fb){
},handle:function(){
},abort:function(){
},fromKwArgs:function(_4fc){
if(_4fc["url"]){
_4fc.url=_4fc.url.toString();
}
if(!_4fc["method"]&&_4fc["formNode"]&&_4fc["formNode"].method){
_4fc.method=_4fc["formNode"].method;
}
if(!_4fc["handle"]&&_4fc["handler"]){
_4fc.handle=_4fc.handler;
}
if(!_4fc["load"]&&_4fc["loaded"]){
_4fc.load=_4fc.loaded;
}
if(!_4fc["changeUrl"]&&_4fc["changeURL"]){
_4fc.changeUrl=_4fc.changeURL;
}
_4fc.encoding=dojo.lang.firstValued(_4fc["encoding"],djConfig["bindEncoding"],"");
_4fc.sendTransport=dojo.lang.firstValued(_4fc["sendTransport"],djConfig["ioSendTransport"],true);
var _4fd=dojo.lang.isFunction;
for(var x=0;x<dojo.io.hdlrFuncNames.length;x++){
var fn=dojo.io.hdlrFuncNames[x];
if(_4fd(_4fc[fn])){
continue;
}
if(_4fd(_4fc["handle"])){
_4fc[fn]=_4fc.handle;
}
}
dojo.lang.mixin(this,_4fc);
}});
dojo.io.Error=function(msg,type,num){
this.message=msg;
this.type=type||"unknown";
this.number=num||0;
};
dojo.io.transports.addTransport=function(name){
this.push(name);
this[name]=dojo.io[name];
};
dojo.io.bind=function(_504){
if(!(_504 instanceof dojo.io.Request)){
try{
_504=new dojo.io.Request(_504);
}
catch(e){
dojo.debug(e);
}
}
var _505="";
if(_504["transport"]){
_505=_504["transport"];
if(!this[_505]){
return _504;
}
}else{
for(var x=0;x<dojo.io.transports.length;x++){
var tmp=dojo.io.transports[x];
if((this[tmp])&&(this[tmp].canHandle(_504))){
_505=tmp;
}
}
if(_505==""){
return _504;
}
}
this[_505].bind(_504);
_504.bindSuccess=true;
return _504;
};
dojo.io.queueBind=function(_508){
if(!(_508 instanceof dojo.io.Request)){
try{
_508=new dojo.io.Request(_508);
}
catch(e){
dojo.debug(e);
}
}
var _509=_508.load;
_508.load=function(){
dojo.io._queueBindInFlight=false;
var ret=_509.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
var _50b=_508.error;
_508.error=function(){
dojo.io._queueBindInFlight=false;
var ret=_50b.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
dojo.io._bindQueue.push(_508);
dojo.io._dispatchNextQueueBind();
return _508;
};
dojo.io._dispatchNextQueueBind=function(){
if(!dojo.io._queueBindInFlight){
dojo.io._queueBindInFlight=true;
dojo.io.bind(dojo.io._bindQueue.shift());
}
};
dojo.io._bindQueue=[];
dojo.io._queueBindInFlight=false;
dojo.io.argsFromMap=function(map,_50e){
var _50f=new Object();
var _510="";
var enc=/utf/i.test(_50e||"")?encodeURIComponent:dojo.string.encodeAscii;
for(var x in map){
if(!_50f[x]){
_510+=enc(x)+"="+enc(map[x])+"&";
}
}
return _510;
};
dojo.provide("dojo.io.BrowserIO");
dojo.require("dojo.io");
dojo.require("dojo.lang");
dojo.require("dojo.dom");
try{
if((!djConfig["preventBackButtonFix"])&&(!dojo.hostenv.post_load_)){
document.write("<iframe style='border: 0px; width: 1px; height: 1px; position: absolute; bottom: 0px; right: 0px; visibility: visible;' name='djhistory' id='djhistory' src='"+(dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"'></iframe>");
}
}
catch(e){
}
dojo.io.checkChildrenForFile=function(node){
var _514=false;
var _515=node.getElementsByTagName("input");
dojo.lang.forEach(_515,function(_516){
if(_514){
return;
}
if(_516.getAttribute("type")=="file"){
_514=true;
}
});
return _514;
};
dojo.io.formHasFile=function(_517){
return dojo.io.checkChildrenForFile(_517);
};
dojo.io.encodeForm=function(_518,_519){
if((!_518)||(!_518.tagName)||(!_518.tagName.toLowerCase()=="form")){
dojo.raise("Attempted to encode a non-form element.");
}
var enc=/utf/i.test(_519||"")?encodeURIComponent:dojo.string.encodeAscii;
var _51b=[];
for(var i=0;i<_518.elements.length;i++){
var elm=_518.elements[i];
if(elm.disabled||elm.tagName.toLowerCase()=="fieldset"||!elm.name){
continue;
}
var name=enc(elm.name);
var type=elm.type.toLowerCase();
if(type=="select-multiple"){
for(var j=0;j<elm.options.length;j++){
if(elm.options[j].selected){
_51b.push(name+"="+enc(elm.options[j].value));
}
}
}else{
if(dojo.lang.inArray(type,["radio","checkbox"])){
if(elm.checked){
_51b.push(name+"="+enc(elm.value));
}
}else{
if(!dojo.lang.inArray(type,["file","submit","reset","button"])){
_51b.push(name+"="+enc(elm.value));
}
}
}
}
var _521=_518.getElementsByTagName("input");
for(var i=0;i<_521.length;i++){
var _522=_521[i];
if(_522.type.toLowerCase()=="image"&&_522.form==_518){
var name=enc(_522.name);
_51b.push(name+"="+enc(_522.value));
_51b.push(name+".x=0");
_51b.push(name+".y=0");
}
}
return _51b.join("&")+"&";
};
dojo.io.setIFrameSrc=function(_523,src,_525){
try{
var r=dojo.render.html;
if(!_525){
if(r.safari){
_523.location=src;
}else{
frames[_523.name].location=src;
}
}else{
var idoc;
if(r.ie){
idoc=_523.contentWindow.document;
}else{
if(r.moz){
idoc=_523.contentWindow;
}else{
if(r.safari){
idoc=_523.document;
}
}
}
idoc.location.replace(src);
}
}
catch(e){
dojo.debug(e);
dojo.debug("setIFrameSrc: "+e);
}
};
dojo.io.XMLHTTPTransport=new function(){
var _528=this;
this.initialHref=window.location.href;
this.initialHash=window.location.hash;
this.moveForward=false;
var _529={};
this.useCache=false;
this.preventCache=false;
this.historyStack=[];
this.forwardStack=[];
this.historyIframe=null;
this.bookmarkAnchor=null;
this.locationTimer=null;
function getCacheKey(url,_52b,_52c){
return url+"|"+_52b+"|"+_52c.toLowerCase();
}
function addToCache(url,_52e,_52f,http){
_529[getCacheKey(url,_52e,_52f)]=http;
}
function getFromCache(url,_532,_533){
return _529[getCacheKey(url,_532,_533)];
}
this.clearCache=function(){
_529={};
};
function doLoad(_534,http,url,_537,_538){
if((http.status==200)||(location.protocol=="file:"&&http.status==0)){
var ret;
if(_534.method.toLowerCase()=="head"){
var _53a=http.getAllResponseHeaders();
ret={};
ret.toString=function(){
return _53a;
};
var _53b=_53a.split(/[\r\n]+/g);
for(var i=0;i<_53b.length;i++){
var pair=_53b[i].match(/^([^:]+)\s*:\s*(.+)$/i);
if(pair){
ret[pair[1]]=pair[2];
}
}
}else{
if(_534.mimetype=="text/javascript"){
try{
ret=dj_eval(http.responseText);
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=null;
}
}else{
if(_534.mimetype=="text/json"){
try{
ret=dj_eval("("+http.responseText+")");
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=false;
}
}else{
if((_534.mimetype=="application/xml")||(_534.mimetype=="text/xml")){
ret=http.responseXML;
if(!ret||typeof ret=="string"){
ret=dojo.dom.createDocumentFromText(http.responseText);
}
}else{
ret=http.responseText;
}
}
}
}
if(_538){
addToCache(url,_537,_534.method,http);
}
_534[(typeof _534.load=="function")?"load":"handle"]("load",ret,http);
}else{
var _53e=new dojo.io.Error("XMLHttpTransport Error: "+http.status+" "+http.statusText);
_534[(typeof _534.error=="function")?"error":"handle"]("error",_53e,http);
}
}
function setHeaders(http,_540){
if(_540["headers"]){
for(var _541 in _540["headers"]){
if(_541.toLowerCase()=="content-type"&&!_540["contentType"]){
_540["contentType"]=_540["headers"][_541];
}else{
http.setRequestHeader(_541,_540["headers"][_541]);
}
}
}
}
this.addToHistory=function(args){
var _543=args["back"]||args["backButton"]||args["handle"];
var hash=null;
if(!this.historyIframe){
this.historyIframe=window.frames["djhistory"];
}
if(!this.bookmarkAnchor){
this.bookmarkAnchor=document.createElement("a");
(document.body||document.getElementsByTagName("body")[0]).appendChild(this.bookmarkAnchor);
this.bookmarkAnchor.style.display="none";
}
if((!args["changeUrl"])||(dojo.render.html.ie)){
var url=dojo.hostenv.getBaseScriptUri()+"iframe_history.html?"+(new Date()).getTime();
this.moveForward=true;
dojo.io.setIFrameSrc(this.historyIframe,url,false);
}
if(args["changeUrl"]){
hash="#"+((args["changeUrl"]!==true)?args["changeUrl"]:(new Date()).getTime());
setTimeout("window.location.href = '"+hash+"';",1);
this.bookmarkAnchor.href=hash;
if(dojo.render.html.ie){
var _546=_543;
var lh=null;
var hsl=this.historyStack.length-1;
if(hsl>=0){
while(!this.historyStack[hsl]["urlHash"]){
hsl--;
}
lh=this.historyStack[hsl]["urlHash"];
}
if(lh){
_543=function(){
if(window.location.hash!=""){
setTimeout("window.location.href = '"+lh+"';",1);
}
_546();
};
}
this.forwardStack=[];
var _549=args["forward"]||args["forwardButton"];
var tfw=function(){
if(window.location.hash!=""){
window.location.href=hash;
}
if(_549){
_549();
}
};
if(args["forward"]){
args.forward=tfw;
}else{
if(args["forwardButton"]){
args.forwardButton=tfw;
}
}
}else{
if(dojo.render.html.moz){
if(!this.locationTimer){
this.locationTimer=setInterval("dojo.io.XMLHTTPTransport.checkLocation();",200);
}
}
}
}
this.historyStack.push({"url":url,"callback":_543,"kwArgs":args,"urlHash":hash});
};
this.checkLocation=function(){
var hsl=this.historyStack.length;
if((window.location.hash==this.initialHash)||(window.location.href==this.initialHref)&&(hsl==1)){
this.handleBackButton();
return;
}
if(this.forwardStack.length>0){
if(this.forwardStack[this.forwardStack.length-1].urlHash==window.location.hash){
this.handleForwardButton();
return;
}
}
if((hsl>=2)&&(this.historyStack[hsl-2])){
if(this.historyStack[hsl-2].urlHash==window.location.hash){
this.handleBackButton();
return;
}
}
};
this.iframeLoaded=function(evt,_54d){
var isp=_54d.href.split("?");
if(isp.length<2){
if(this.historyStack.length==1){
this.handleBackButton();
}
return;
}
var _54f=isp[1];
if(this.moveForward){
this.moveForward=false;
return;
}
var last=this.historyStack.pop();
if(!last){
if(this.forwardStack.length>0){
var next=this.forwardStack[this.forwardStack.length-1];
if(_54f==next.url.split("?")[1]){
this.handleForwardButton();
}
}
return;
}
this.historyStack.push(last);
if(this.historyStack.length>=2){
if(isp[1]==this.historyStack[this.historyStack.length-2].url.split("?")[1]){
this.handleBackButton();
}
}else{
this.handleBackButton();
}
};
this.handleBackButton=function(){
var last=this.historyStack.pop();
if(!last){
return;
}
if(last["callback"]){
last.callback();
}else{
if(last.kwArgs["backButton"]){
last.kwArgs["backButton"]();
}else{
if(last.kwArgs["back"]){
last.kwArgs["back"]();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("back");
}
}
}
}
this.forwardStack.push(last);
};
this.handleForwardButton=function(){
var last=this.forwardStack.pop();
if(!last){
return;
}
if(last.kwArgs["forward"]){
last.kwArgs.forward();
}else{
if(last.kwArgs["forwardButton"]){
last.kwArgs.forwardButton();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("forward");
}
}
}
this.historyStack.push(last);
};
this.inFlight=[];
this.inFlightTimer=null;
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setInterval("dojo.io.XMLHTTPTransport.watchInFlight();",10);
}
};
this.watchInFlight=function(){
for(var x=this.inFlight.length-1;x>=0;x--){
var tif=this.inFlight[x];
if(!tif){
this.inFlight.splice(x,1);
continue;
}
if(4==tif.http.readyState){
this.inFlight.splice(x,1);
doLoad(tif.req,tif.http,tif.url,tif.query,tif.useCache);
if(this.inFlight.length==0){
clearInterval(this.inFlightTimer);
this.inFlightTimer=null;
}
}
}
};
var _556=dojo.hostenv.getXmlhttpObject()?true:false;
this.canHandle=function(_557){
return _556&&dojo.lang.inArray((_557["mimetype"]||"".toLowerCase()),["text/plain","text/html","application/xml","text/xml","text/javascript","text/json"])&&dojo.lang.inArray(_557["method"].toLowerCase(),["post","get","head"])&&!(_557["formNode"]&&dojo.io.formHasFile(_557["formNode"]));
};
this.multipartBoundary="45309FFF-BD65-4d50-99C9-36986896A96F";
this.bind=function(_558){
if(!_558["url"]){
if(!_558["formNode"]&&(_558["backButton"]||_558["back"]||_558["changeUrl"]||_558["watchForURL"])&&(!djConfig.preventBackButtonFix)){
this.addToHistory(_558);
return true;
}
}
var url=_558.url;
var _55a="";
if(_558["formNode"]){
var ta=_558.formNode.getAttribute("action");
if((ta)&&(!_558["url"])){
url=ta;
}
var tp=_558.formNode.getAttribute("method");
if((tp)&&(!_558["method"])){
_558.method=tp;
}
_55a+=dojo.io.encodeForm(_558.formNode,_558.encoding);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
if(_558["file"]){
_558.method="post";
}
if(!_558["method"]){
_558.method="get";
}
if(_558.method.toLowerCase()=="get"){
_558.multipart=false;
}else{
if(_558["file"]){
_558.multipart=true;
}else{
if(!_558["multipart"]){
_558.multipart=false;
}
}
}
if(_558["backButton"]||_558["back"]||_558["changeUrl"]){
this.addToHistory(_558);
}
var _55d=_558["content"]||{};
if(_558.sendTransport){
_55d["dojo.transport"]="xmlhttp";
}
do{
if(_558.postContent){
_55a=_558.postContent;
break;
}
if(_55d){
_55a+=dojo.io.argsFromMap(_55d,_558.encoding);
}
if(_558.method.toLowerCase()=="get"||!_558.multipart){
break;
}
var t=[];
if(_55a.length){
var q=_55a.split("&");
for(var i=0;i<q.length;++i){
if(q[i].length){
var p=q[i].split("=");
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+p[0]+"\"","",p[1]);
}
}
}
if(_558.file){
if(dojo.lang.isArray(_558.file)){
for(var i=0;i<_558.file.length;++i){
var o=_558.file[i];
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}else{
var o=_558.file;
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}
if(t.length){
t.push("--"+this.multipartBoundary+"--","");
_55a=t.join("\r\n");
}
}while(false);
var _563=_558["sync"]?false:true;
var _564=_558["preventCache"]||(this.preventCache==true&&_558["preventCache"]!=false);
var _565=_558["useCache"]==true||(this.useCache==true&&_558["useCache"]!=false);
if(!_564&&_565){
var _566=getFromCache(url,_55a,_558.method);
if(_566){
doLoad(_558,_566,url,_55a,false);
return;
}
}
var http=dojo.hostenv.getXmlhttpObject();
var _568=false;
if(_563){
this.inFlight.push({"req":_558,"http":http,"url":url,"query":_55a,"useCache":_565});
this.startWatchingInFlight();
}
if(_558.method.toLowerCase()=="post"){
http.open("POST",url,_563);
setHeaders(http,_558);
http.setRequestHeader("Content-Type",_558.multipart?("multipart/form-data; boundary="+this.multipartBoundary):(_558.contentType||"application/x-www-form-urlencoded"));
http.send(_55a);
}else{
var _569=url;
if(_55a!=""){
_569+=(_569.indexOf("?")>-1?"&":"?")+_55a;
}
if(_564){
_569+=(dojo.string.endsWithAny(_569,"?","&")?"":(_569.indexOf("?")>-1?"&":"?"))+"dojo.preventCache="+new Date().valueOf();
}
http.open(_558.method.toUpperCase(),_569,_563);
setHeaders(http,_558);
http.send(null);
}
if(!_563){
doLoad(_558,http,url,_55a,_565);
}
_558.abort=function(){
return http.abort();
};
return;
};
dojo.io.transports.addTransport("XMLHTTPTransport");
};
dojo.provide("dojo.io.cookie");
dojo.io.cookie.setCookie=function(name,_56b,days,path,_56e,_56f){
var _570=-1;
if(typeof days=="number"&&days>=0){
var d=new Date();
d.setTime(d.getTime()+(days*24*60*60*1000));
_570=d.toGMTString();
}
_56b=escape(_56b);
document.cookie=name+"="+_56b+";"+(_570!=-1?" expires="+_570+";":"")+(path?"path="+path:"")+(_56e?"; domain="+_56e:"")+(_56f?"; secure":"");
};
dojo.io.cookie.set=dojo.io.cookie.setCookie;
dojo.io.cookie.getCookie=function(name){
var idx=document.cookie.indexOf(name+"=");
if(idx==-1){
return null;
}
value=document.cookie.substring(idx+name.length+1);
var end=value.indexOf(";");
if(end==-1){
end=value.length;
}
value=value.substring(0,end);
value=unescape(value);
return value;
};
dojo.io.cookie.get=dojo.io.cookie.getCookie;
dojo.io.cookie.deleteCookie=function(name){
dojo.io.cookie.setCookie(name,"-",0);
};
dojo.io.cookie.setObjectCookie=function(name,obj,days,path,_57a,_57b,_57c){
if(arguments.length==5){
_57c=_57a;
_57a=null;
_57b=null;
}
var _57d=[],cookie,value="";
if(!_57c){
cookie=dojo.io.cookie.getObjectCookie(name);
}
if(days>=0){
if(!cookie){
cookie={};
}
for(var prop in obj){
if(prop==null){
delete cookie[prop];
}else{
if(typeof obj[prop]=="string"||typeof obj[prop]=="number"){
cookie[prop]=obj[prop];
}
}
}
prop=null;
for(var prop in cookie){
_57d.push(escape(prop)+"="+escape(cookie[prop]));
}
value=_57d.join("&");
}
dojo.io.cookie.setCookie(name,value,days,path,_57a,_57b);
};
dojo.io.cookie.getObjectCookie=function(name){
var _580=null,cookie=dojo.io.cookie.getCookie(name);
if(cookie){
_580={};
var _581=cookie.split("&");
for(var i=0;i<_581.length;i++){
var pair=_581[i].split("=");
var _584=pair[1];
if(isNaN(_584)){
_584=unescape(pair[1]);
}
_580[unescape(pair[0])]=_584;
}
}
return _580;
};
dojo.io.cookie.isSupported=function(){
if(typeof navigator.cookieEnabled!="boolean"){
dojo.io.cookie.setCookie("__TestingYourBrowserForCookieSupport__","CookiesAllowed",90,null);
var _585=dojo.io.cookie.getCookie("__TestingYourBrowserForCookieSupport__");
navigator.cookieEnabled=(_585=="CookiesAllowed");
if(navigator.cookieEnabled){
this.deleteCookie("__TestingYourBrowserForCookieSupport__");
}
}
return navigator.cookieEnabled;
};
if(!dojo.io.cookies){
dojo.io.cookies=dojo.io.cookie;
}
dojo.hostenv.conditionalLoadModule({common:["dojo.io",false,false],rhino:["dojo.io.RhinoIO",false,false],browser:[["dojo.io.BrowserIO",false,false],["dojo.io.cookie",false,false]]});
dojo.hostenv.moduleLoaded("dojo.io.*");
dojo.hostenv.conditionalLoadModule({common:["dojo.uri.Uri",false,false]});
dojo.hostenv.moduleLoaded("dojo.uri.*");
dojo.provide("dojo.io.IframeIO");
dojo.require("dojo.io.BrowserIO");
dojo.require("dojo.uri.*");
dojo.io.createIFrame=function(_586,_587){
if(window[_586]){
return window[_586];
}
if(window.frames[_586]){
return window.frames[_586];
}
var r=dojo.render.html;
var _589=null;
var turi=dojo.uri.dojoUri("iframe_history.html?noInit=true");
var _58b=((r.ie)&&(dojo.render.os.win))?"<iframe name='"+_586+"' src='"+turi+"' onload='"+_587+"'>":"iframe";
_589=document.createElement(_58b);
with(_589){
name=_586;
setAttribute("name",_586);
id=_586;
}
(document.body||document.getElementsByTagName("body")[0]).appendChild(_589);
window[_586]=_589;
with(_589.style){
position="absolute";
left=top="0px";
height=width="1px";
visibility="hidden";
}
if(!r.ie){
dojo.io.setIFrameSrc(_589,turi,true);
_589.onload=new Function(_587);
}
return _589;
};
dojo.io.iframeContentWindow=function(_58c){
var win=_58c.contentWindow||dojo.io.iframeContentDocument(_58c).defaultView||dojo.io.iframeContentDocument(_58c).__parent__||(_58c.name&&document.frames[_58c.name])||null;
return win;
};
dojo.io.iframeContentDocument=function(_58e){
var doc=_58e.contentDocument||((_58e.contentWindow)&&(_58e.contentWindow.document))||((_58e.name)&&(document.frames[_58e.name])&&(document.frames[_58e.name].document))||null;
return doc;
};
dojo.io.IframeTransport=new function(){
var _590=this;
this.currentRequest=null;
this.requestQueue=[];
this.iframeName="dojoIoIframe";
this.fireNextRequest=function(){
if((this.currentRequest)||(this.requestQueue.length==0)){
return;
}
var cr=this.currentRequest=this.requestQueue.shift();
var fn=cr["formNode"];
var _593=cr["content"]||{};
if(cr.sendTransport){
_593["dojo.transport"]="iframe";
}
if(fn){
if(_593){
for(var x in _593){
if(!fn[x]){
var tn;
if(dojo.render.html.ie){
tn=document.createElement("<input type='hidden' name='"+x+"' value='"+_593[x]+"'>");
fn.appendChild(tn);
}else{
tn=document.createElement("input");
fn.appendChild(tn);
tn.type="hidden";
tn.name=x;
tn.value=_593[x];
}
}else{
fn[x].value=_593[x];
}
}
}
if(cr["url"]){
fn.setAttribute("action",cr.url);
}
if(!fn.getAttribute("method")){
fn.setAttribute("method",(cr["method"])?cr["method"]:"post");
}
fn.setAttribute("target",this.iframeName);
fn.target=this.iframeName;
fn.submit();
}else{
var _596=dojo.io.argsFromMap(this.currentRequest.content);
var _597=(cr.url.indexOf("?")>-1?"&":"?")+_596;
dojo.io.setIFrameSrc(this.iframe,_597,true);
}
};
this.canHandle=function(_598){
return ((dojo.lang.inArray(_598["mimetype"],["text/plain","text/html","application/xml","text/xml","text/javascript","text/json"]))&&((_598["formNode"])&&(dojo.io.checkChildrenForFile(_598["formNode"])))&&(dojo.lang.inArray(_598["method"].toLowerCase(),["post","get"]))&&(!((_598["sync"])&&(_598["sync"]==true))));
};
this.bind=function(_599){
this.requestQueue.push(_599);
this.fireNextRequest();
return;
};
this.setUpIframe=function(){
this.iframe=dojo.io.createIFrame(this.iframeName,"dojo.io.IframeTransport.iframeOnload();");
};
this.iframeOnload=function(){
if(!_590.currentRequest){
_590.fireNextRequest();
return;
}
var ifr=_590.iframe;
var ifw=dojo.io.iframeContentWindow(ifr);
var _59c;
var _59d=false;
try{
var cmt=_590.currentRequest.mimetype;
if((cmt=="text/javascript")||(cmt=="text/json")){
var cd=dojo.io.iframeContentDocument(_590.iframe);
var js=cd.getElementsByTagName("textarea")[0].value;
if(cmt=="text/json"){
js="("+js+")";
}
_59c=dj_eval(js);
}else{
if((cmt=="application/xml")||(cmt=="text/xml")){
_59c=dojo.io.iframeContentDocument(_590.iframe);
}else{
_59c=ifw.innerHTML;
}
}
_59d=true;
}
catch(e){
var _5a1=new dojo.io.Error("IframeTransport Error");
if(dojo.lang.isFunction(_590.currentRequest["error"])){
_590.currentRequest.error("error",_5a1,_590.currentRequest);
}
}
try{
if(_59d&&dojo.lang.isFunction(_590.currentRequest["load"])){
_590.currentRequest.load("load",_59c,_590.currentRequest);
}
}
catch(e){
throw e;
}
finally{
_590.currentRequest=null;
_590.fireNextRequest();
}
};
dojo.io.transports.addTransport("IframeTransport");
};
dojo.addOnLoad(function(){
dojo.io.IframeTransport.setUpIframe();
});
dojo.provide("dojo.date");
dojo.require("dojo.string");
dojo.date.setIso8601=function(_5a2,_5a3){
var _5a4=_5a3.split("T");
dojo.date.setIso8601Date(_5a2,_5a4[0]);
if(_5a4.length==2){
dojo.date.setIso8601Time(_5a2,_5a4[1]);
}
return _5a2;
};
dojo.date.fromIso8601=function(_5a5){
return dojo.date.setIso8601(new Date(0),_5a5);
};
dojo.date.setIso8601Date=function(_5a6,_5a7){
var _5a8="^([0-9]{4})((-?([0-9]{2})(-?([0-9]{2}))?)|"+"(-?([0-9]{3}))|(-?W([0-9]{2})(-?([1-7]))?))?$";
var d=_5a7.match(new RegExp(_5a8));
var year=d[1];
var _5ab=d[4];
var date=d[6];
var _5ad=d[8];
var week=d[10];
var _5af=(d[12])?d[12]:1;
_5a6.setYear(year);
if(_5ad){
dojo.date.setDayOfYear(_5a6,Number(_5ad));
}else{
if(week){
_5a6.setMonth(0);
_5a6.setDate(1);
var gd=_5a6.getDay();
var day=(gd)?gd:7;
var _5b2=Number(_5af)+(7*Number(week));
if(day<=4){
_5a6.setDate(_5b2+1-day);
}else{
_5a6.setDate(_5b2+8-day);
}
}else{
if(_5ab){
_5a6.setMonth(_5ab-1);
}
if(date){
_5a6.setDate(date);
}
}
}
return _5a6;
};
dojo.date.fromIso8601Date=function(_5b3){
return dojo.date.setIso8601Date(new Date(0),_5b3);
};
dojo.date.setIso8601Time=function(_5b4,_5b5){
var _5b6="Z|(([-+])([0-9]{2})(:?([0-9]{2}))?)$";
var d=_5b5.match(new RegExp(_5b6));
var _5b8=0;
if(d){
if(d[0]!="Z"){
_5b8=(Number(d[3])*60)+Number(d[5]);
_5b8*=((d[2]=="-")?1:-1);
}
_5b8-=_5b4.getTimezoneOffset();
_5b5=_5b5.substr(0,_5b5.length-d[0].length);
}
var _5b9="^([0-9]{2})(:?([0-9]{2})(:?([0-9]{2})(.([0-9]+))?)?)?$";
var d=_5b5.match(new RegExp(_5b9));
var _5ba=d[1];
var mins=Number((d[3])?d[3]:0)+_5b8;
var secs=(d[5])?d[5]:0;
var ms=d[7]?(Number("0."+d[7])*1000):0;
_5b4.setHours(_5ba);
_5b4.setMinutes(mins);
_5b4.setSeconds(secs);
_5b4.setMilliseconds(ms);
return _5b4;
};
dojo.date.fromIso8601Time=function(_5be){
return dojo.date.setIso8601Time(new Date(0),_5be);
};
dojo.date.setDayOfYear=function(_5bf,_5c0){
_5bf.setMonth(0);
_5bf.setDate(_5c0);
return _5bf;
};
dojo.date.getDayOfYear=function(_5c1){
var _5c2=new Date("1/1/"+_5c1.getFullYear());
return Math.floor((_5c1.getTime()-_5c2.getTime())/86400000);
};
dojo.date.getWeekOfYear=function(_5c3){
return Math.ceil(dojo.date.getDayOfYear(_5c3)/7);
};
dojo.date.daysInMonth=function(_5c4,year){
dojo.deprecated("daysInMonth(month, year)","replaced by getDaysInMonth(dateObject)","0.4");
return dojo.date.getDaysInMonth(new Date(year,_5c4,1));
};
dojo.date.getDaysInMonth=function(_5c6){
var _5c7=_5c6.getMonth();
var year=_5c6.getFullYear();
var days=[31,28,31,30,31,30,31,31,30,31,30,31];
if(_5c7==1&&year){
if((!(year%4)&&(year%100))||(!(year%4)&&!(year%100)&&!(year%400))){
return 29;
}else{
return 28;
}
}else{
return days[_5c7];
}
};
dojo.date.months=["January","February","March","April","May","June","July","August","September","October","November","December"];
dojo.date.shortMonths=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"];
dojo.date.days=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
dojo.date.shortDays=["Sun","Mon","Tues","Wed","Thur","Fri","Sat"];
dojo.date.toLongDateString=function(date){
return dojo.date.months[date.getMonth()]+" "+date.getDate()+", "+date.getFullYear();
};
dojo.date.toShortDateString=function(date){
return dojo.date.shortMonths[date.getMonth()]+" "+date.getDate()+", "+date.getFullYear();
};
dojo.date.toMilitaryTimeString=function(date){
var h="00"+date.getHours();
var m="00"+date.getMinutes();
var s="00"+date.getSeconds();
return h.substr(h.length-2,2)+":"+m.substr(m.length-2,2)+":"+s.substr(s.length-2,2);
};
dojo.date.toRelativeString=function(date){
var now=new Date();
var diff=(now-date)/1000;
var end=" ago";
var _5d4=false;
if(diff<0){
_5d4=true;
end=" from now";
diff=-diff;
}
if(diff<60){
diff=Math.round(diff);
return diff+" second"+(diff==1?"":"s")+end;
}else{
if(diff<3600){
diff=Math.round(diff/60);
return diff+" minute"+(diff==1?"":"s")+end;
}else{
if(diff<3600*24&&date.getDay()==now.getDay()){
diff=Math.round(diff/3600);
return diff+" hour"+(diff==1?"":"s")+end;
}else{
if(diff<3600*24*7){
diff=Math.round(diff/(3600*24));
if(diff==1){
return _5d4?"Tomorrow":"Yesterday";
}else{
return diff+" days"+end;
}
}else{
return dojo.date.toShortDateString(date);
}
}
}
}
};
dojo.date.getDayOfWeekName=function(date){
return dojo.date.days[date.getDay()];
};
dojo.date.getShortDayOfWeekName=function(date){
return dojo.date.shortDays[date.getDay()];
};
dojo.date.getMonthName=function(date){
return dojo.date.months[date.getMonth()];
};
dojo.date.getShortMonthName=function(date){
return dojo.date.shortMonths[date.getMonth()];
};
dojo.date.toString=function(date,_5da){
if(_5da.indexOf("#d")>-1){
_5da=_5da.replace(/#dddd/g,dojo.date.getDayOfWeekName(date));
_5da=_5da.replace(/#ddd/g,dojo.date.getShortDayOfWeekName(date));
_5da=_5da.replace(/#dd/g,(date.getDate().toString().length==1?"0":"")+date.getDate());
_5da=_5da.replace(/#d/g,date.getDate());
}
if(_5da.indexOf("#M")>-1){
_5da=_5da.replace(/#MMMM/g,dojo.date.getMonthName(date));
_5da=_5da.replace(/#MMM/g,dojo.date.getShortMonthName(date));
_5da=_5da.replace(/#MM/g,((date.getMonth()+1).toString().length==1?"0":"")+(date.getMonth()+1));
_5da=_5da.replace(/#M/g,date.getMonth()+1);
}
if(_5da.indexOf("#y")>-1){
var _5db=date.getFullYear().toString();
_5da=_5da.replace(/#yyyy/g,_5db);
_5da=_5da.replace(/#yy/g,_5db.substring(2));
_5da=_5da.replace(/#y/g,_5db.substring(3));
}
if(_5da.indexOf("#")==-1){
return _5da;
}
if(_5da.indexOf("#h")>-1){
var _5dc=date.getHours();
_5dc=(_5dc>12?_5dc-12:(_5dc==0)?12:_5dc);
_5da=_5da.replace(/#hh/g,(_5dc.toString().length==1?"0":"")+_5dc);
_5da=_5da.replace(/#h/g,_5dc);
}
if(_5da.indexOf("#H")>-1){
_5da=_5da.replace(/#HH/g,(date.getHours().toString().length==1?"0":"")+date.getHours());
_5da=_5da.replace(/#H/g,date.getHours());
}
if(_5da.indexOf("#m")>-1){
_5da=_5da.replace(/#mm/g,(date.getMinutes().toString().length==1?"0":"")+date.getMinutes());
_5da=_5da.replace(/#m/g,date.getMinutes());
}
if(_5da.indexOf("#s")>-1){
_5da=_5da.replace(/#ss/g,(date.getSeconds().toString().length==1?"0":"")+date.getSeconds());
_5da=_5da.replace(/#s/g,date.getSeconds());
}
if(_5da.indexOf("#T")>-1){
_5da=_5da.replace(/#TT/g,date.getHours()>=12?"PM":"AM");
_5da=_5da.replace(/#T/g,date.getHours()>=12?"P":"A");
}
if(_5da.indexOf("#t")>-1){
_5da=_5da.replace(/#tt/g,date.getHours()>=12?"pm":"am");
_5da=_5da.replace(/#t/g,date.getHours()>=12?"p":"a");
}
return _5da;
};
dojo.date.toSql=function(date,_5de){
var sql=date.getFullYear()+"-"+dojo.string.pad(date.getMonth(),2)+"-"+dojo.string.pad(date.getDate(),2);
if(!_5de){
sql+=" "+dojo.string.pad(date.getHours(),2)+":"+dojo.string.pad(date.getMinutes(),2)+":"+dojo.string.pad(date.getSeconds(),2);
}
return sql;
};
dojo.date.fromSql=function(_5e0){
var _5e1=_5e0.split(/[\- :]/g);
while(_5e1.length<6){
_5e1.push(0);
}
return new Date(_5e1[0],_5e1[1],_5e1[2],_5e1[3],_5e1[4],_5e1[5]);
};
dojo.provide("dojo.string.Builder");
dojo.require("dojo.string");
dojo.string.Builder=function(str){
this.arrConcat=(dojo.render.html.capable&&dojo.render.html["ie"]);
var a=[];
var b=str||"";
var _5e5=this.length=b.length;
if(this.arrConcat){
if(b.length>0){
a.push(b);
}
b="";
}
this.toString=this.valueOf=function(){
return (this.arrConcat)?a.join(""):b;
};
this.append=function(s){
if(this.arrConcat){
a.push(s);
}else{
b+=s;
}
_5e5+=s.length;
this.length=_5e5;
return this;
};
this.clear=function(){
a=[];
b="";
_5e5=this.length=0;
return this;
};
this.remove=function(f,l){
var s="";
if(this.arrConcat){
b=a.join("");
}
a=[];
if(f>0){
s=b.substring(0,(f-1));
}
b=s+b.substring(f+l);
_5e5=this.length=b.length;
if(this.arrConcat){
a.push(b);
b="";
}
return this;
};
this.replace=function(o,n){
if(this.arrConcat){
b=a.join("");
}
a=[];
b=b.replace(o,n);
_5e5=this.length=b.length;
if(this.arrConcat){
a.push(b);
b="";
}
return this;
};
this.insert=function(idx,s){
if(this.arrConcat){
b=a.join("");
}
a=[];
if(idx==0){
b=s+b;
}else{
var t=b.split("");
t.splice(idx,0,s);
b=t.join("");
}
_5e5=this.length=b.length;
if(this.arrConcat){
a.push(b);
b="";
}
return this;
};
};
dojo.hostenv.conditionalLoadModule({common:["dojo.string","dojo.string.Builder"]});
dojo.hostenv.moduleLoaded("dojo.string.*");
if(!this["dojo"]){
alert("\"dojo/__package__.js\" is now located at \"dojo/dojo.js\". Please update your includes accordingly");
}
dojo.provide("dojo.json");
dojo.require("dojo.lang");
dojo.json={jsonRegistry:new dojo.AdapterRegistry(),register:function(name,_5f0,wrap,_5f2){
dojo.json.jsonRegistry.register(name,_5f0,wrap,_5f2);
},evalJSON:function(){
return eval("("+arguments[0]+")");
},serialize:function(o){
var _5f4=typeof (o);
if(_5f4=="undefined"){
return "undefined";
}else{
if((_5f4=="number")||(_5f4=="boolean")){
return o+"";
}else{
if(o===null){
return "null";
}
}
}
var m=dojo.lang;
if(_5f4=="string"){
return m.reprString(o);
}
var me=arguments.callee;
var _5f7;
if(typeof (o.__json__)=="function"){
_5f7=o.__json__();
if(o!==_5f7){
return me(_5f7);
}
}
if(typeof (o.json)=="function"){
_5f7=o.json();
if(o!==_5f7){
return me(_5f7);
}
}
if(_5f4!="function"&&typeof (o.length)=="number"){
var res=[];
for(var i=0;i<o.length;i++){
var val=me(o[i]);
if(typeof (val)!="string"){
val="undefined";
}
res.push(val);
}
return "["+res.join(",")+"]";
}
try{
window.o=o;
_5f7=dojo.json.jsonRegistry.match(o);
return me(_5f7);
}
catch(e){
}
if(_5f4=="function"){
return null;
}
res=[];
for(var k in o){
var _5fc;
if(typeof (k)=="number"){
_5fc="\""+k+"\"";
}else{
if(typeof (k)=="string"){
_5fc=m.reprString(k);
}else{
continue;
}
}
val=me(o[k]);
if(typeof (val)!="string"){
continue;
}
res.push(_5fc+":"+val);
}
return "{"+res.join(",")+"}";
}};
dojo.provide("dojo.rpc.Deferred");
dojo.require("dojo.lang");
dojo.rpc.Deferred=function(_5fd){
this.chain=[];
this.id=this._nextId();
this.fired=-1;
this.paused=0;
this.results=[null,null];
this.canceller=_5fd;
this.silentlyCancelled=false;
};
dojo.lang.extend(dojo.rpc.Deferred,{getFunctionFromArgs:function(){
var a=arguments;
if((a[0])&&(!a[1])){
if(dojo.lang.isFunction(a[0])){
return a[0];
}else{
if(dojo.lang.isString(a[0])){
return dj_global[a[0]];
}
}
}else{
if((a[0])&&(a[1])){
return dojo.lang.hitch(a[0],a[1]);
}
}
return null;
},repr:function(){
var _5ff;
if(this.fired==-1){
_5ff="unfired";
}else{
if(this.fired==0){
_5ff="success";
}else{
_5ff="error";
}
}
return "Deferred("+this.id+", "+_5ff+")";
},toString:dojo.lang.forward("repr"),_nextId:(function(){
var n=1;
return function(){
return n++;
};
})(),cancel:function(){
if(this.fired==-1){
if(this.canceller){
this.canceller(this);
}else{
this.silentlyCancelled=true;
}
if(this.fired==-1){
this.errback(new Error(this.repr()));
}
}else{
if((this.fired==0)&&(this.results[0] instanceof dojo.rpc.Deferred)){
this.results[0].cancel();
}
}
},_pause:function(){
this.paused++;
},_unpause:function(){
this.paused--;
if((this.paused==0)&&(this.fired>=0)){
this._fire();
}
},_continue:function(res){
this._resback(res);
this._unpause();
},_resback:function(res){
this.fired=((res instanceof Error)?1:0);
this.results[this.fired]=res;
this._fire();
},_check:function(){
if(this.fired!=-1){
if(!this.silentlyCancelled){
dojo.raise("already called!");
}
this.silentlyCancelled=false;
return;
}
},callback:function(res){
this._check();
this._resback(res);
},errback:function(res){
this._check();
if(!(res instanceof Error)){
res=new Error(res);
}
this._resback(res);
},addBoth:function(cb,cbfn){
var _607=this.getFunctionFromArgs(cb,cbfn);
if(arguments.length>2){
_607=dojo.lang.curryArguments(null,_607,arguments,2);
}
return this.addCallbacks(_607,_607);
},addCallback:function(cb,cbfn){
var _60a=this.getFunctionFromArgs(cb,cbfn);
if(arguments.length>2){
_60a=dojo.lang.curryArguments(null,_60a,arguments,2);
}
return this.addCallbacks(_60a,null);
},addErrback:function(cb,cbfn){
var _60d=this.getFunctionFromArgs(cb,cbfn);
if(arguments.length>2){
_60d=dojo.lang.curryArguments(null,_60d,arguments,2);
}
return this.addCallbacks(null,_60d);
return this.addCallbacks(null,fn);
},addCallbacks:function(cb,eb){
this.chain.push([cb,eb]);
if(this.fired>=0){
this._fire();
}
return this;
},_fire:function(){
var _610=this.chain;
var _611=this.fired;
var res=this.results[_611];
var self=this;
var cb=null;
while(_610.length>0&&this.paused==0){
var pair=_610.shift();
var f=pair[_611];
if(f==null){
continue;
}
try{
res=f(res);
_611=((res instanceof Error)?1:0);
if(res instanceof dojo.rpc.Deferred){
cb=function(res){
self._continue(res);
};
this._pause();
}
}
catch(err){
_611=1;
res=err;
}
}
this.fired=_611;
this.results[_611]=res;
if((cb)&&(this.paused)){
res.addBoth(cb);
}
}});
dojo.provide("dojo.rpc.RpcService");
dojo.require("dojo.io.*");
dojo.require("dojo.json");
dojo.require("dojo.lang");
dojo.require("dojo.rpc.Deferred");
dojo.rpc.RpcService=function(url){
if(url){
this.connect(url);
}
};
dojo.lang.extend(dojo.rpc.RpcService,{strictArgChecks:true,serviceUrl:"",parseResults:function(obj){
return obj;
},errorCallback:function(_61a){
return function(type,obj,e){
_61a.errback(e);
};
},resultCallback:function(_61e){
var tf=dojo.lang.hitch(this,function(type,obj,e){
var _623=this.parseResults(obj);
_61e.callback(_623);
});
return tf;
},generateMethod:function(_624,_625){
var _626=this;
return function(){
var _627=new dojo.rpc.Deferred();
if((!_626.strictArgChecks)||((_625!=null)&&(arguments.length!=_625.length))){
dojo.raise("Invalid number of parameters for remote method.");
}else{
_626.bind(_624,arguments,_627);
}
return _627;
};
},processSmd:function(_628){
dojo.debug("RpcService: Processing returned SMD.");
for(var n=0;n<_628.methods.length;n++){
dojo.debug("RpcService: Creating Method: this.",_628.methods[n].name,"()");
this[_628.methods[n].name]=this.generateMethod(_628.methods[n].name,_628.methods[n].parameters);
if(dojo.lang.isFunction(this[_628.methods[n].name])){
dojo.debug("RpcService: Successfully created",_628.methods[n].name,"()");
}else{
dojo.debug("RpcService: Failed to create",_628.methods[n].name,"()");
}
}
this.serviceUrl=_628.serviceUrl||_628.serviceURL;
dojo.debug("RpcService: Dojo RpcService is ready for use.");
},connect:function(_62a){
dojo.debug("RpcService: Attempting to load SMD document from:",_62a);
dojo.io.bind({url:_62a,mimetype:"text/json",load:dojo.lang.hitch(this,function(type,_62c,e){
return this.processSmd(_62c);
}),sync:true});
}});
dojo.provide("dojo.rpc.JsonService");
dojo.require("dojo.rpc.RpcService");
dojo.require("dojo.io.*");
dojo.require("dojo.json");
dojo.require("dojo.lang");
dojo.rpc.JsonService=function(args){
if(args){
if(dojo.lang.isString(args)){
this.connect(args);
}else{
if(args["smdUrl"]){
this.connect(args.smdUrl);
}
if(args["smdStr"]){
this.processSmd(dj_eval("("+args.smdStr+")"));
}
if(args["smdObj"]){
this.processSmd(args.smdObj);
}
if(args["serviceUrl"]){
this.serviceUrl=args.serviceUrl;
}
if(args["strictArgChecks"]){
this.strictArgChecks=args.strictArgChecks;
}
}
}
};
dojo.inherits(dojo.rpc.JsonService,dojo.rpc.RpcService);
dojo.lang.extend(dojo.rpc.JsonService,{bustCache:false,lastSubmissionId:0,callRemote:function(_62f,_630){
var _631=new dojo.rpc.Deferred();
this.bind(_62f,_630,_631);
return _631;
},bind:function(_632,_633,_634){
dojo.io.bind({url:this.serviceUrl,postContent:this.createRequest(_632,_633),method:"POST",mimetype:"text/json",load:this.resultCallback(_634),preventCache:this.bustCache});
},createRequest:function(_635,_636){
var req={"params":_636,"method":_635,"id":this.lastSubmissionId++};
var data=dojo.json.serialize(req);
dojo.debug("JsonService: JSON-RPC Request: "+data);
return data;
},parseResults:function(obj){
if(obj["result"]){
return obj["result"];
}else{
return obj;
}
}});
dojo.hostenv.conditionalLoadModule({common:["dojo.rpc.JsonService",false,false]});
dojo.hostenv.moduleLoaded("dojo.rpc.*");
dojo.provide("dojo.xml.Parse");
dojo.require("dojo.dom");
dojo.xml.Parse=function(){
this.parseFragment=function(_63a){
var _63b={};
var _63c=dojo.dom.getTagName(_63a);
_63b[_63c]=new Array(_63a.tagName);
var _63d=this.parseAttributes(_63a);
for(var attr in _63d){
if(!_63b[attr]){
_63b[attr]=[];
}
_63b[attr][_63b[attr].length]=_63d[attr];
}
var _63f=_63a.childNodes;
for(var _640 in _63f){
switch(_63f[_640].nodeType){
case dojo.dom.ELEMENT_NODE:
_63b[_63c].push(this.parseElement(_63f[_640]));
break;
case dojo.dom.TEXT_NODE:
if(_63f.length==1){
if(!_63b[_63a.tagName]){
_63b[_63c]=[];
}
_63b[_63c].push({value:_63f[0].nodeValue});
}
break;
}
}
return _63b;
};
this.parseElement=function(node,_642,_643,_644){
var _645={};
var _646=dojo.dom.getTagName(node);
_645[_646]=[];
if((!_643)||(_646.substr(0,4).toLowerCase()=="dojo")){
var _647=this.parseAttributes(node);
for(var attr in _647){
if((!_645[_646][attr])||(typeof _645[_646][attr]!="array")){
_645[_646][attr]=[];
}
_645[_646][attr].push(_647[attr]);
}
_645[_646].nodeRef=node;
_645.tagName=_646;
_645.index=_644||0;
}
var _649=0;
for(var i=0;i<node.childNodes.length;i++){
var tcn=node.childNodes.item(i);
switch(tcn.nodeType){
case dojo.dom.ELEMENT_NODE:
_649++;
var ctn=dojo.dom.getTagName(tcn);
if(!_645[ctn]){
_645[ctn]=[];
}
_645[ctn].push(this.parseElement(tcn,true,_643,_649));
if((tcn.childNodes.length==1)&&(tcn.childNodes.item(0).nodeType==dojo.dom.TEXT_NODE)){
_645[ctn][_645[ctn].length-1].value=tcn.childNodes.item(0).nodeValue;
}
break;
case dojo.dom.TEXT_NODE:
if(node.childNodes.length==1){
_645[_646].push({value:node.childNodes.item(0).nodeValue});
}
break;
default:
break;
}
}
return _645;
};
this.parseAttributes=function(node){
var _64e={};
var atts=node.attributes;
for(var i=0;i<atts.length;i++){
var _651=atts.item(i);
if((dojo.render.html.capable)&&(dojo.render.html.ie)){
if(!_651){
continue;
}
if((typeof _651=="object")&&(typeof _651.nodeValue=="undefined")||(_651.nodeValue==null)||(_651.nodeValue=="")){
continue;
}
}
var nn=(_651.nodeName.indexOf("dojo:")==-1)?_651.nodeName:_651.nodeName.split("dojo:")[1];
_64e[nn]={value:_651.nodeValue};
}
return _64e;
};
};
dojo.provide("dojo.xml.domUtil");
dojo.require("dojo.graphics.color");
dojo.require("dojo.dom");
dojo.require("dojo.style");
dj_deprecated("dojo.xml.domUtil is deprecated, use dojo.dom instead");
dojo.xml.domUtil=new function(){
this.nodeTypes={ELEMENT_NODE:1,ATTRIBUTE_NODE:2,TEXT_NODE:3,CDATA_SECTION_NODE:4,ENTITY_REFERENCE_NODE:5,ENTITY_NODE:6,PROCESSING_INSTRUCTION_NODE:7,COMMENT_NODE:8,DOCUMENT_NODE:9,DOCUMENT_TYPE_NODE:10,DOCUMENT_FRAGMENT_NODE:11,NOTATION_NODE:12};
this.dojoml="http://www.dojotoolkit.org/2004/dojoml";
this.idIncrement=0;
this.getTagName=function(){
return dojo.dom.getTagName.apply(dojo.dom,arguments);
};
this.getUniqueId=function(){
return dojo.dom.getUniqueId.apply(dojo.dom,arguments);
};
this.getFirstChildTag=function(){
return dojo.dom.getFirstChildElement.apply(dojo.dom,arguments);
};
this.getLastChildTag=function(){
return dojo.dom.getLastChildElement.apply(dojo.dom,arguments);
};
this.getNextSiblingTag=function(){
return dojo.dom.getNextSiblingElement.apply(dojo.dom,arguments);
};
this.getPreviousSiblingTag=function(){
return dojo.dom.getPreviousSiblingElement.apply(dojo.dom,arguments);
};
this.forEachChildTag=function(node,_654){
var _655=this.getFirstChildTag(node);
while(_655){
if(_654(_655)=="break"){
break;
}
_655=this.getNextSiblingTag(_655);
}
};
this.moveChildren=function(){
return dojo.dom.moveChildren.apply(dojo.dom,arguments);
};
this.copyChildren=function(){
return dojo.dom.copyChildren.apply(dojo.dom,arguments);
};
this.clearChildren=function(){
return dojo.dom.removeChildren.apply(dojo.dom,arguments);
};
this.replaceChildren=function(){
return dojo.dom.replaceChildren.apply(dojo.dom,arguments);
};
this.getStyle=function(){
return dojo.style.getStyle.apply(dojo.style,arguments);
};
this.toCamelCase=function(){
return dojo.style.toCamelCase.apply(dojo.style,arguments);
};
this.toSelectorCase=function(){
return dojo.style.toSelectorCase.apply(dojo.style,arguments);
};
this.getAncestors=function(){
return dojo.dom.getAncestors.apply(dojo.dom,arguments);
};
this.isChildOf=function(){
return dojo.dom.isDescendantOf.apply(dojo.dom,arguments);
};
this.createDocumentFromText=function(){
return dojo.dom.createDocumentFromText.apply(dojo.dom,arguments);
};
if(dojo.render.html.capable||dojo.render.svg.capable){
this.createNodesFromText=function(txt,wrap){
return dojo.dom.createNodesFromText.apply(dojo.dom,arguments);
};
}
this.extractRGB=function(_658){
return dojo.graphics.color.extractRGB(_658);
};
this.hex2rgb=function(hex){
return dojo.graphics.color.hex2rgb(hex);
};
this.rgb2hex=function(r,g,b){
return dojo.graphics.color.rgb2hex(r,g,b);
};
this.insertBefore=function(){
return dojo.dom.insertBefore.apply(dojo.dom,arguments);
};
this.before=this.insertBefore;
this.insertAfter=function(){
return dojo.dom.insertAfter.apply(dojo.dom,arguments);
};
this.after=this.insertAfter;
this.insert=function(){
return dojo.dom.insertAtPosition.apply(dojo.dom,arguments);
};
this.insertAtIndex=function(){
return dojo.dom.insertAtIndex.apply(dojo.dom,arguments);
};
this.textContent=function(){
return dojo.dom.textContent.apply(dojo.dom,arguments);
};
this.renderedTextContent=function(){
return dojo.dom.renderedTextContent.apply(dojo.dom,arguments);
};
this.remove=function(node){
return dojo.dom.removeNode.apply(dojo.dom,arguments);
};
};
dojo.provide("dojo.xml.htmlUtil");
dojo.require("dojo.html");
dojo.require("dojo.style");
dojo.require("dojo.dom");
dj_deprecated("dojo.xml.htmlUtil is deprecated, use dojo.html instead");
dojo.xml.htmlUtil=new function(){
this.styleSheet=dojo.style.styleSheet;
this._clobberSelection=function(){
return dojo.html.clearSelection.apply(dojo.html,arguments);
};
this.disableSelect=function(){
return dojo.html.disableSelection.apply(dojo.html,arguments);
};
this.enableSelect=function(){
return dojo.html.enableSelection.apply(dojo.html,arguments);
};
this.getInnerWidth=function(){
return dojo.style.getInnerWidth.apply(dojo.style,arguments);
};
this.getOuterWidth=function(node){
dj_unimplemented("dojo.xml.htmlUtil.getOuterWidth");
};
this.getInnerHeight=function(){
return dojo.style.getInnerHeight.apply(dojo.style,arguments);
};
this.getOuterHeight=function(node){
dj_unimplemented("dojo.xml.htmlUtil.getOuterHeight");
};
this.getTotalOffset=function(){
return dojo.style.getTotalOffset.apply(dojo.style,arguments);
};
this.totalOffsetLeft=function(){
return dojo.style.totalOffsetLeft.apply(dojo.style,arguments);
};
this.getAbsoluteX=this.totalOffsetLeft;
this.totalOffsetTop=function(){
return dojo.style.totalOffsetTop.apply(dojo.style,arguments);
};
this.getAbsoluteY=this.totalOffsetTop;
this.getEventTarget=function(){
return dojo.html.getEventTarget.apply(dojo.html,arguments);
};
this.getScrollTop=function(){
return dojo.html.getScrollTop.apply(dojo.html,arguments);
};
this.getScrollLeft=function(){
return dojo.html.getScrollLeft.apply(dojo.html,arguments);
};
this.evtTgt=this.getEventTarget;
this.getParentOfType=function(){
return dojo.html.getParentOfType.apply(dojo.html,arguments);
};
this.getAttribute=function(){
return dojo.html.getAttribute.apply(dojo.html,arguments);
};
this.getAttr=function(node,attr){
dj_deprecated("dojo.xml.htmlUtil.getAttr is deprecated, use dojo.xml.htmlUtil.getAttribute instead");
return dojo.xml.htmlUtil.getAttribute(node,attr);
};
this.hasAttribute=function(){
return dojo.html.hasAttribute.apply(dojo.html,arguments);
};
this.hasAttr=function(node,attr){
dj_deprecated("dojo.xml.htmlUtil.hasAttr is deprecated, use dojo.xml.htmlUtil.hasAttribute instead");
return dojo.xml.htmlUtil.hasAttribute(node,attr);
};
this.getClass=function(){
return dojo.html.getClass.apply(dojo.html,arguments);
};
this.hasClass=function(){
return dojo.html.hasClass.apply(dojo.html,arguments);
};
this.prependClass=function(){
return dojo.html.prependClass.apply(dojo.html,arguments);
};
this.addClass=function(){
return dojo.html.addClass.apply(dojo.html,arguments);
};
this.setClass=function(){
return dojo.html.setClass.apply(dojo.html,arguments);
};
this.removeClass=function(){
return dojo.html.removeClass.apply(dojo.html,arguments);
};
this.classMatchType={ContainsAll:0,ContainsAny:1,IsOnly:2};
this.getElementsByClass=function(){
return dojo.html.getElementsByClass.apply(dojo.html,arguments);
};
this.getElementsByClassName=this.getElementsByClass;
this.setOpacity=function(){
return dojo.style.setOpacity.apply(dojo.style,arguments);
};
this.getOpacity=function(){
return dojo.style.getOpacity.apply(dojo.style,arguments);
};
this.clearOpacity=function(){
return dojo.style.clearOpacity.apply(dojo.style,arguments);
};
this.gravity=function(){
return dojo.html.gravity.apply(dojo.html,arguments);
};
this.gravity.NORTH=1;
this.gravity.SOUTH=1<<1;
this.gravity.EAST=1<<2;
this.gravity.WEST=1<<3;
this.overElement=function(){
return dojo.html.overElement.apply(dojo.html,arguments);
};
this.insertCssRule=function(){
return dojo.style.insertCssRule.apply(dojo.style,arguments);
};
this.insertCSSRule=function(_664,_665,_666){
dj_deprecated("dojo.xml.htmlUtil.insertCSSRule is deprecated, use dojo.xml.htmlUtil.insertCssRule instead");
return dojo.xml.htmlUtil.insertCssRule(_664,_665,_666);
};
this.removeCssRule=function(){
return dojo.style.removeCssRule.apply(dojo.style,arguments);
};
this.removeCSSRule=function(_667){
dj_deprecated("dojo.xml.htmlUtil.removeCSSRule is deprecated, use dojo.xml.htmlUtil.removeCssRule instead");
return dojo.xml.htmlUtil.removeCssRule(_667);
};
this.insertCssFile=function(){
return dojo.style.insertCssFile.apply(dojo.style,arguments);
};
this.insertCSSFile=function(URI,doc,_66a){
dj_deprecated("dojo.xml.htmlUtil.insertCSSFile is deprecated, use dojo.xml.htmlUtil.insertCssFile instead");
return dojo.xml.htmlUtil.insertCssFile(URI,doc,_66a);
};
this.getBackgroundColor=function(){
return dojo.style.getBackgroundColor.apply(dojo.style,arguments);
};
this.getUniqueId=function(){
return dojo.dom.getUniqueId();
};
this.getStyle=function(){
return dojo.style.getStyle.apply(dojo.style,arguments);
};
};
dojo.require("dojo.xml.Parse");
dojo.hostenv.conditionalLoadModule({common:["dojo.xml.domUtil"],browser:["dojo.xml.htmlUtil"],svg:["dojo.xml.svgUtil"]});
dojo.hostenv.moduleLoaded("dojo.xml.*");
dojo.hostenv.conditionalLoadModule({common:["dojo.lang"]});
dojo.hostenv.moduleLoaded("dojo.lang.*");
dojo.require("dojo.lang.*");
dojo.provide("dojo.storage");
dojo.provide("dojo.storage.StorageProvider");
dojo.storage=new function(){
this.provider=null;
this.setProvider=function(obj){
this.provider=obj;
};
this.set=function(key,_66d,_66e){
if(!this.provider){
return false;
}
return this.provider.set(key,_66d,_66e);
};
this.get=function(key,_670){
if(!this.provider){
return false;
}
return this.provider.get(key,_670);
};
this.remove=function(key,_672){
return this.provider.remove(key,_672);
};
};
dojo.storage.StorageProvider=function(){
};
dojo.lang.extend(dojo.storage.StorageProvider,{namespace:"*",initialized:false,free:function(){
dojo.unimplemented("dojo.storage.StorageProvider.free");
return 0;
},freeK:function(){
return dojo.math.round(this.free()/1024,0);
},set:function(key,_674,_675){
dojo.unimplemented("dojo.storage.StorageProvider.set");
},get:function(key,_677){
dojo.unimplemented("dojo.storage.StorageProvider.get");
},remove:function(key,_679,_67a){
dojo.unimplemented("dojo.storage.StorageProvider.set");
}});
dojo.provide("dojo.storage.browser");
dojo.require("dojo.storage");
dojo.require("dojo.uri.*");
dojo.storage.browser.StorageProvider=function(){
this.initialized=false;
this.flash=null;
this.backlog=[];
};
dojo.inherits(dojo.storage.browser.StorageProvider,dojo.storage.StorageProvider);
dojo.lang.extend(dojo.storage.browser.StorageProvider,{storageOnLoad:function(){
this.initialized=true;
this.hideStore();
while(this.backlog.length){
this.set.apply(this,this.backlog.shift());
}
},unHideStore:function(){
var _67b=dojo.byId("dojo-storeContainer");
with(_67b.style){
position="absolute";
overflow="visible";
width="215px";
height="138px";
left="30px";
top="30px";
visiblity="visible";
zIndex="20";
border="1px solid black";
}
},hideStore:function(_67c){
var _67d=dojo.byId("dojo-storeContainer");
with(_67d.style){
left="-300px";
top="-300px";
}
},set:function(key,_67f,ns){
if(!this.initialized){
this.backlog.push([key,_67f,ns]);
return "pending";
}
return this.flash.set(key,_67f,ns||this.namespace);
},get:function(key,ns){
return this.flash.get(key,ns||this.namespace);
},writeStorage:function(){
var _683=dojo.uri.dojoUri("src/storage/Storage.swf").toString();
var _684=["<div id=\"dojo-storeContainer\"","style=\"position: absolute; left: -300px; top: -300px;\">"];
if(dojo.render.html.ie){
_684.push("<object");
_684.push("\tstyle=\"border: 1px solid black;\"");
_684.push("\tclassid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\"");
_684.push("\tcodebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0\"");
_684.push("\twidth=\"215\" height=\"138\" id=\"dojoStorage\">");
_684.push("\t<param name=\"movie\" value=\""+_683+"\">");
_684.push("\t<param name=\"quality\" value=\"high\">");
_684.push("</object>");
}else{
_684.push("<embed src=\""+_683+"\" width=\"215\" height=\"138\" ");
_684.push("\tquality=\"high\" ");
_684.push("\tpluginspage=\"http://www.macromedia.com/go/getflashplayer\" ");
_684.push("\ttype=\"application/x-shockwave-flash\" ");
_684.push("\tname=\"dojoStorage\">");
_684.push("</embed>");
}
_684.push("</div>");
document.write(_684.join(""));
}});
dojo.storage.setProvider(new dojo.storage.browser.StorageProvider());
dojo.storage.provider.writeStorage();
dojo.addOnLoad(function(){
dojo.storage.provider.flash=(dojo.render.html.ie)?window["dojoStorage"]:document["dojoStorage"];
});
dojo.hostenv.conditionalLoadModule({common:["dojo.storage"],browser:["dojo.storage.browser"]});
dojo.hostenv.moduleLoaded("dojo.storage.*");
dojo.provide("dojo.crypto");
dojo.crypto.cipherModes={ECB:0,CBC:1,PCBC:2,CFB:3,OFB:4,CTR:5};
dojo.crypto.outputTypes={Base64:0,Hex:1,String:2,Raw:3};
dojo.require("dojo.crypto");
dojo.provide("dojo.crypto.MD5");
dojo.crypto.MD5=new function(){
var _685=8;
var mask=(1<<_685)-1;
function toWord(s){
var wa=[];
for(var i=0;i<s.length*_685;i+=_685){
wa[i>>5]|=(s.charCodeAt(i/_685)&mask)<<(i%32);
}
return wa;
}
function toString(wa){
var s=[];
for(var i=0;i<wa.length*32;i+=_685){
s.push(String.fromCharCode((wa[i>>5]>>>(i%32))&mask));
}
return s.join("");
}
function toHex(wa){
var h="0123456789abcdef";
var s=[];
for(var i=0;i<wa.length*4;i++){
s.push(h.charAt((wa[i>>2]>>((i%4)*8+4))&15)+h.charAt((wa[i>>2]>>((i%4)*8))&15));
}
return s.join("");
}
function toBase64(wa){
var p="=";
var tab="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
var s=[];
for(var i=0;i<wa.length*4;i+=3){
var t=(((wa[i>>2]>>8*(i%4))&255)<<16)|(((wa[i+1>>2]>>8*((i+1)%4))&255)<<8)|((wa[i+2>>2]>>8*((i+2)%4))&255);
for(var j=0;j<4;j++){
if(i*8+j*6>wa.length*32){
s.push(p);
}else{
s.push(tab.charAt((t>>6*(3-j))&63));
}
}
}
return s.join("");
}
function add(x,y){
var l=(x&65535)+(y&65535);
var m=(x>>16)+(y>>16)+(l>>16);
return (m<<16)|(l&65535);
}
function R(n,c){
return (n<<c)|(n>>>(32-c));
}
function C(q,a,b,x,s,t){
return add(R(add(add(a,q),add(x,t)),s),b);
}
function FF(a,b,c,d,x,s,t){
return C((b&c)|((~b)&d),a,b,x,s,t);
}
function GG(a,b,c,d,x,s,t){
return C((b&d)|(c&(~d)),a,b,x,s,t);
}
function HH(a,b,c,d,x,s,t){
return C(b^c^d,a,b,x,s,t);
}
function II(a,b,c,d,x,s,t){
return C(c^(b|(~d)),a,b,x,s,t);
}
function core(x,len){
x[len>>5]|=128<<((len)%32);
x[(((len+64)>>>9)<<4)+14]=len;
var a=1732584193;
var b=-271733879;
var c=-1732584194;
var d=271733878;
for(var i=0;i<x.length;i+=16){
var olda=a;
var oldb=b;
var oldc=c;
var oldd=d;
a=FF(a,b,c,d,x[i+0],7,-680876936);
d=FF(d,a,b,c,x[i+1],12,-389564586);
c=FF(c,d,a,b,x[i+2],17,606105819);
b=FF(b,c,d,a,x[i+3],22,-1044525330);
a=FF(a,b,c,d,x[i+4],7,-176418897);
d=FF(d,a,b,c,x[i+5],12,1200080426);
c=FF(c,d,a,b,x[i+6],17,-1473231341);
b=FF(b,c,d,a,x[i+7],22,-45705983);
a=FF(a,b,c,d,x[i+8],7,1770035416);
d=FF(d,a,b,c,x[i+9],12,-1958414417);
c=FF(c,d,a,b,x[i+10],17,-42063);
b=FF(b,c,d,a,x[i+11],22,-1990404162);
a=FF(a,b,c,d,x[i+12],7,1804603682);
d=FF(d,a,b,c,x[i+13],12,-40341101);
c=FF(c,d,a,b,x[i+14],17,-1502002290);
b=FF(b,c,d,a,x[i+15],22,1236535329);
a=GG(a,b,c,d,x[i+1],5,-165796510);
d=GG(d,a,b,c,x[i+6],9,-1069501632);
c=GG(c,d,a,b,x[i+11],14,643717713);
b=GG(b,c,d,a,x[i+0],20,-373897302);
a=GG(a,b,c,d,x[i+5],5,-701558691);
d=GG(d,a,b,c,x[i+10],9,38016083);
c=GG(c,d,a,b,x[i+15],14,-660478335);
b=GG(b,c,d,a,x[i+4],20,-405537848);
a=GG(a,b,c,d,x[i+9],5,568446438);
d=GG(d,a,b,c,x[i+14],9,-1019803690);
c=GG(c,d,a,b,x[i+3],14,-187363961);
b=GG(b,c,d,a,x[i+8],20,1163531501);
a=GG(a,b,c,d,x[i+13],5,-1444681467);
d=GG(d,a,b,c,x[i+2],9,-51403784);
c=GG(c,d,a,b,x[i+7],14,1735328473);
b=GG(b,c,d,a,x[i+12],20,-1926607734);
a=HH(a,b,c,d,x[i+5],4,-378558);
d=HH(d,a,b,c,x[i+8],11,-2022574463);
c=HH(c,d,a,b,x[i+11],16,1839030562);
b=HH(b,c,d,a,x[i+14],23,-35309556);
a=HH(a,b,c,d,x[i+1],4,-1530992060);
d=HH(d,a,b,c,x[i+4],11,1272893353);
c=HH(c,d,a,b,x[i+7],16,-155497632);
b=HH(b,c,d,a,x[i+10],23,-1094730640);
a=HH(a,b,c,d,x[i+13],4,681279174);
d=HH(d,a,b,c,x[i+0],11,-358537222);
c=HH(c,d,a,b,x[i+3],16,-722521979);
b=HH(b,c,d,a,x[i+6],23,76029189);
a=HH(a,b,c,d,x[i+9],4,-640364487);
d=HH(d,a,b,c,x[i+12],11,-421815835);
c=HH(c,d,a,b,x[i+15],16,530742520);
b=HH(b,c,d,a,x[i+2],23,-995338651);
a=II(a,b,c,d,x[i+0],6,-198630844);
d=II(d,a,b,c,x[i+7],10,1126891415);
c=II(c,d,a,b,x[i+14],15,-1416354905);
b=II(b,c,d,a,x[i+5],21,-57434055);
a=II(a,b,c,d,x[i+12],6,1700485571);
d=II(d,a,b,c,x[i+3],10,-1894986606);
c=II(c,d,a,b,x[i+10],15,-1051523);
b=II(b,c,d,a,x[i+1],21,-2054922799);
a=II(a,b,c,d,x[i+8],6,1873313359);
d=II(d,a,b,c,x[i+15],10,-30611744);
c=II(c,d,a,b,x[i+6],15,-1560198380);
b=II(b,c,d,a,x[i+13],21,1309151649);
a=II(a,b,c,d,x[i+4],6,-145523070);
d=II(d,a,b,c,x[i+11],10,-1120210379);
c=II(c,d,a,b,x[i+2],15,718787259);
b=II(b,c,d,a,x[i+9],21,-343485551);
a=add(a,olda);
b=add(b,oldb);
c=add(c,oldc);
d=add(d,oldd);
}
return [a,b,c,d];
}
function hmac(data,key){
var wa=toWord(key);
if(wa.length>16){
wa=core(wa,key.length*_685);
}
var l=[],r=[];
for(var i=0;i<16;i++){
l[i]=wa[i]^909522486;
r[i]=wa[i]^1549556828;
}
var h=core(l.concat(toWord(data)),512+data.length*_685);
return core(r.concat(h),640);
}
this.compute=function(data,_6d2){
var out=_6d2||dojo.crypto.outputTypes.Base64;
switch(out){
case dojo.crypto.outputTypes.Hex:
return toHex(core(toWord(data),data.length*_685));
case dojo.crypto.outputTypes.String:
return toString(core(toWord(data),data.length*_685));
default:
return toBase64(core(toWord(data),data.length*_685));
}
};
this.getHMAC=function(data,key,_6d6){
var out=_6d6||dojo.crypto.outputTypes.Base64;
switch(out){
case dojo.crypto.outputTypes.Hex:
return toHex(hmac(data,key));
case dojo.crypto.outputTypes.String:
return toString(hmac(data,key));
default:
return toBase64(hmac(data,key));
}
};
}();
dojo.hostenv.conditionalLoadModule({common:["dojo.crypto","dojo.crypto.MD5"]});
dojo.hostenv.moduleLoaded("dojo.crypto.*");
dojo.provide("dojo.collections.Collections");
dojo.collections={Collections:true};
dojo.collections.DictionaryEntry=function(k,v){
this.key=k;
this.value=v;
this.valueOf=function(){
return this.value;
};
this.toString=function(){
return this.value;
};
};
dojo.collections.Iterator=function(a){
var obj=a;
var _6dc=0;
this.atEnd=(_6dc>=obj.length-1);
this.current=obj[_6dc];
this.moveNext=function(){
if(++_6dc>=obj.length){
this.atEnd=true;
}
if(this.atEnd){
return false;
}
this.current=obj[_6dc];
return true;
};
this.reset=function(){
_6dc=0;
this.atEnd=false;
this.current=obj[_6dc];
};
};
dojo.collections.DictionaryIterator=function(obj){
var arr=[];
for(var p in obj){
arr.push(obj[p]);
}
var _6e0=0;
this.atEnd=(_6e0>=arr.length-1);
this.current=arr[_6e0]||null;
this.entry=this.current||null;
this.key=(this.entry)?this.entry.key:null;
this.value=(this.entry)?this.entry.value:null;
this.moveNext=function(){
if(++_6e0>=arr.length){
this.atEnd=true;
}
if(this.atEnd){
return false;
}
this.entry=this.current=arr[_6e0];
if(this.entry){
this.key=this.entry.key;
this.value=this.entry.value;
}
return true;
};
this.reset=function(){
_6e0=0;
this.atEnd=false;
this.current=arr[_6e0]||null;
this.entry=this.current||null;
this.key=(this.entry)?this.entry.key:null;
this.value=(this.entry)?this.entry.value:null;
};
};
dojo.provide("dojo.collections.ArrayList");
dojo.require("dojo.collections.Collections");
dojo.collections.ArrayList=function(arr){
var _6e2=[];
if(arr){
_6e2=_6e2.concat(arr);
}
this.count=_6e2.length;
this.add=function(obj){
_6e2.push(obj);
this.count=_6e2.length;
};
this.addRange=function(a){
if(a.getIterator){
var e=a.getIterator();
while(!e.atEnd){
this.add(e.current);
e.moveNext();
}
this.count=_6e2.length;
}else{
for(var i=0;i<a.length;i++){
_6e2.push(a[i]);
}
this.count=_6e2.length;
}
};
this.clear=function(){
_6e2.splice(0,_6e2.length);
this.count=0;
};
this.clone=function(){
return new dojo.collections.ArrayList(_6e2);
};
this.contains=function(obj){
for(var i=0;i<_6e2.length;i++){
if(_6e2[i]==obj){
return true;
}
}
return false;
};
this.getIterator=function(){
return new dojo.collections.Iterator(_6e2);
};
this.indexOf=function(obj){
for(var i=0;i<_6e2.length;i++){
if(_6e2[i]==obj){
return i;
}
}
return -1;
};
this.insert=function(i,obj){
_6e2.splice(i,0,obj);
this.count=_6e2.length;
};
this.item=function(k){
return _6e2[k];
};
this.remove=function(obj){
var i=this.indexOf(obj);
if(i>=0){
_6e2.splice(i,1);
}
this.count=_6e2.length;
};
this.removeAt=function(i){
_6e2.splice(i,1);
this.count=_6e2.length;
};
this.reverse=function(){
_6e2.reverse();
};
this.sort=function(fn){
if(fn){
_6e2.sort(fn);
}else{
_6e2.sort();
}
};
this.setByIndex=function(i,obj){
_6e2[i]=obj;
this.count=_6e2.length;
};
this.toArray=function(){
return [].concat(_6e2);
};
this.toString=function(){
return _6e2.join(",");
};
};
dojo.provide("dojo.collections.Queue");
dojo.require("dojo.collections.Collections");
dojo.collections.Queue=function(arr){
var q=[];
if(arr){
q=q.concat(arr);
}
this.count=q.length;
this.clear=function(){
q=[];
this.count=q.length;
};
this.clone=function(){
return new dojo.collections.Queue(q);
};
this.contains=function(o){
for(var i=0;i<q.length;i++){
if(q[i]==o){
return true;
}
}
return false;
};
this.copyTo=function(arr,i){
arr.splice(i,0,q);
};
this.dequeue=function(){
var r=q.shift();
this.count=q.length;
return r;
};
this.enqueue=function(o){
this.count=q.push(o);
};
this.getIterator=function(){
return new dojo.collections.Iterator(q);
};
this.peek=function(){
return q[0];
};
this.toArray=function(){
return [].concat(q);
};
};
dojo.provide("dojo.collections.Stack");
dojo.require("dojo.collections.Collections");
dojo.collections.Stack=function(arr){
var q=[];
if(arr){
q=q.concat(arr);
}
this.count=q.length;
this.clear=function(){
q=[];
this.count=q.length;
};
this.clone=function(){
return new dojo.collections.Stack(q);
};
this.contains=function(o){
for(var i=0;i<q.length;i++){
if(q[i]==o){
return true;
}
}
return false;
};
this.copyTo=function(arr,i){
arr.splice(i,0,q);
};
this.getIterator=function(){
return new dojo.collections.Iterator(q);
};
this.peek=function(){
return q[(q.length-1)];
};
this.pop=function(){
var r=q.pop();
this.count=q.length;
return r;
};
this.push=function(o){
this.count=q.push(o);
};
this.toArray=function(){
return [].concat(q);
};
};
dojo.provide("dojo.graphics.htmlEffects");
dojo.require("dojo.fx.*");
dj_deprecated("dojo.graphics.htmlEffects is deprecated, use dojo.fx.html instead");
dojo.graphics.htmlEffects=dojo.fx.html;
dojo.hostenv.conditionalLoadModule({browser:["dojo.graphics.htmlEffects"]});
dojo.hostenv.moduleLoaded("dojo.graphics.*");
dojo.require("dojo.lang");
dojo.provide("dojo.dnd.DragSource");
dojo.provide("dojo.dnd.DropTarget");
dojo.provide("dojo.dnd.DragObject");
dojo.provide("dojo.dnd.DragManager");
dojo.provide("dojo.dnd.DragAndDrop");
dojo.dnd.DragSource=function(){
dojo.dnd.dragManager.registerDragSource(this);
};
dojo.lang.extend(dojo.dnd.DragSource,{type:"",onDragEnd:function(){
},onDragStart:function(){
},unregister:function(){
dojo.dnd.dragManager.unregisterDragSource(this);
},reregister:function(){
dojo.dnd.dragManager.registerDragSource(this);
}});
dojo.dnd.DragObject=function(){
dojo.dnd.dragManager.registerDragObject(this);
};
dojo.lang.extend(dojo.dnd.DragObject,{type:"",onDragStart:function(){
},onDragMove:function(){
},onDragOver:function(){
},onDragOut:function(){
},onDragEnd:function(){
},onDragLeave:this.onDragOut,onDragEnter:this.onDragOver,ondragout:this.onDragOut,ondragover:this.onDragOver});
dojo.dnd.DropTarget=function(){
if(this.constructor==dojo.dnd.DropTarget){
return;
}
this.acceptedTypes=[];
dojo.dnd.dragManager.registerDropTarget(this);
};
dojo.lang.extend(dojo.dnd.DropTarget,{acceptedTypes:[],acceptsType:function(type){
if(!dojo.lang.inArray(this.acceptedTypes,"*")){
if(!dojo.lang.inArray(this.acceptedTypes,type)){
return false;
}
}
return true;
},accepts:function(_705){
if(!dojo.lang.inArray(this.acceptedTypes,"*")){
for(var i=0;i<_705.length;i++){
if(!dojo.lang.inArray(this.acceptedTypes,_705[i].type)){
return false;
}
}
}
return true;
},onDragOver:function(){
},onDragOut:function(){
},onDragMove:function(){
},onDrop:function(){
}});
dojo.dnd.DragEvent=function(){
this.dragSource=null;
this.dragObject=null;
this.target=null;
this.eventStatus="success";
};
dojo.dnd.DragManager=function(){
};
dojo.lang.extend(dojo.dnd.DragManager,{selectedSources:[],dragObjects:[],dragSources:[],registerDragSource:function(){
},dropTargets:[],registerDropTarget:function(){
},lastDragTarget:null,currentDragTarget:null,onKeyDown:function(){
},onMouseOut:function(){
},onMouseMove:function(){
},onMouseUp:function(){
}});
dojo.provide("dojo.dnd.HtmlDragManager");
dojo.require("dojo.event.*");
dojo.require("dojo.lang");
dojo.require("dojo.html");
dojo.require("dojo.style");
dojo.dnd.HtmlDragManager=function(){
};
dojo.inherits(dojo.dnd.HtmlDragManager,dojo.dnd.DragManager);
dojo.lang.extend(dojo.dnd.HtmlDragManager,{disabled:false,nestedTargets:false,mouseDownTimer:null,dsCounter:0,dsPrefix:"dojoDragSource",dropTargetDimensions:[],currentDropTarget:null,currentDropTargetPoints:null,previousDropTarget:null,_dragTriggered:false,selectedSources:[],dragObjects:[],currentX:null,currentY:null,lastX:null,lastY:null,mouseDownX:null,mouseDownY:null,threshold:7,dropAcceptable:false,registerDragSource:function(ds){
if(ds["domNode"]){
var dp=this.dsPrefix;
var _709=dp+"Idx_"+(this.dsCounter++);
ds.dragSourceId=_709;
this.dragSources[_709]=ds;
ds.domNode.setAttribute(dp,_709);
}
},unregisterDragSource:function(ds){
if(ds["domNode"]){
var dp=this.dsPrefix;
var _70c=ds.dragSourceId;
delete ds.dragSourceId;
delete this.dragSources[_70c];
ds.domNode.setAttribute(dp,null);
}
},registerDropTarget:function(dt){
this.dropTargets.push(dt);
},getDragSource:function(e){
var tn=e.target;
if(tn===dojo.html.body()){
return;
}
var ta=dojo.html.getAttribute(tn,this.dsPrefix);
while((!ta)&&(tn)){
tn=tn.parentNode;
if((!tn)||(tn===dojo.html.body())){
return;
}
ta=dojo.html.getAttribute(tn,this.dsPrefix);
}
return this.dragSources[ta];
},onKeyDown:function(e){
},onMouseDown:function(e){
if(this.disabled){
return;
}
this.mouseDownX=e.clientX;
this.mouseDownY=e.clientY;
var _713=e.target.nodeType==dojo.dom.TEXT_NODE?e.target.parentNode:e.target;
switch(_713.tagName.toLowerCase()){
case "a":
case "button":
case "textarea":
case "input":
return;
}
var ds=this.getDragSource(e);
if(!ds){
return;
}
if(!dojo.lang.inArray(this.selectedSources,ds)){
this.selectedSources.push(ds);
}
e.preventDefault();
dojo.event.connect(document,"onmousemove",this,"onMouseMove");
},onMouseUp:function(e){
this.mouseDownX=null;
this.mouseDownY=null;
this._dragTriggered=false;
var _716=this;
e.dragSource=this.dragSource;
if((!e.shiftKey)&&(!e.ctrlKey)){
dojo.lang.forEach(this.dragObjects,function(_717){
var ret=null;
if(!_717){
return;
}
if(_716.currentDropTarget){
e.dragObject=_717;
var ce=_716.currentDropTarget.domNode.childNodes;
if(ce.length>0){
e.dropTarget=ce[0];
while(e.dropTarget==_717.domNode){
e.dropTarget=e.dropTarget.nextSibling;
}
}else{
e.dropTarget=_716.currentDropTarget.domNode;
}
if(_716.dropAcceptable){
ret=_716.currentDropTarget.onDrop(e);
}else{
_716.currentDropTarget.onDragOut(e);
}
}
e.dragStatus=_716.dropAcceptable&&ret?"dropSuccess":"dropFailure";
_717.onDragEnd(e);
});
this.selectedSources=[];
this.dragObjects=[];
this.dragSource=null;
}
dojo.event.disconnect(document,"onmousemove",this,"onMouseMove");
this.currentDropTarget=null;
this.currentDropTargetPoints=null;
},scrollBy:function(x,y){
for(var i=0;i<this.dragObjects.length;i++){
if(this.dragObjects[i].updateDragOffset){
this.dragObjects[i].updateDragOffset();
}
}
},_dragStartDistance:function(x,y){
if((!this.mouseDownX)||(!this.mouseDownX)){
return;
}
var dx=Math.abs(x-this.mouseDownX);
var dx2=dx*dx;
var dy=Math.abs(y-this.mouseDownY);
var dy2=dy*dy;
return parseInt(Math.sqrt(dx2+dy2),10);
},onMouseMove:function(e){
var _724=this;
if((this.selectedSources.length)&&(!this.dragObjects.length)){
var dx;
var dy;
if(!this._dragTriggered){
this._dragTriggered=(this._dragStartDistance(e.clientX,e.clientY)>this.threshold);
if(!this._dragTriggered){
return;
}
dx=e.clientX-this.mouseDownX;
dy=e.clientY-this.mouseDownY;
}
if(this.selectedSources.length==1){
this.dragSource=this.selectedSources[0];
}
dojo.lang.forEach(this.selectedSources,function(_727){
if(!_727){
return;
}
var tdo=_727.onDragStart(e);
if(tdo){
tdo.onDragStart(e);
tdo.dragOffset.top+=dy;
tdo.dragOffset.left+=dx;
_724.dragObjects.push(tdo);
}
});
this.dropTargetDimensions=[];
dojo.lang.forEach(this.dropTargets,function(_729){
var tn=_729.domNode;
if(!tn){
return;
}
var ttx=dojo.style.getAbsoluteX(tn,true);
var tty=dojo.style.getAbsoluteY(tn,true);
_724.dropTargetDimensions.push([[ttx,tty],[ttx+dojo.style.getInnerWidth(tn),tty+dojo.style.getInnerHeight(tn)],_729]);
});
}
for(var i=0;i<this.dragObjects.length;i++){
if(this.dragObjects[i]){
this.dragObjects[i].onDragMove(e);
}
}
var dtp=this.currentDropTargetPoints;
if((!this.nestedTargets)&&(dtp)&&(this.isInsideBox(e,dtp))){
if(this.dropAcceptable){
this.currentDropTarget.onDragMove(e,this.dragObjects);
}
}else{
var _72f=this.findBestTarget(e);
if(_72f.target==null){
if(this.currentDropTarget){
this.currentDropTarget.onDragOut(e);
this.currentDropTarget=null;
this.currentDropTargetPoints=null;
}
this.dropAcceptable=false;
return;
}
if(this.currentDropTarget!=_72f.target){
if(this.currentDropTarget){
this.currentDropTarget.onDragOut(e);
}
this.currentDropTarget=_72f.target;
this.currentDropTargetPoints=_72f.points;
e.dragObjects=this.dragObjects;
this.dropAcceptable=this.currentDropTarget.onDragOver(e);
}else{
if(this.dropAcceptable){
this.currentDropTarget.onDragMove(e,this.dragObjects);
}
}
}
},findBestTarget:function(e){
var _731=this;
var _732=new Object();
_732.target=null;
_732.points=null;
dojo.lang.forEach(this.dropTargetDimensions,function(_733){
if(_731.isInsideBox(e,_733)){
_732.target=_733[2];
_732.points=_733;
if(!_731.nestedTargets){
return "break";
}
}
});
return _732;
},isInsideBox:function(e,_735){
if((e.clientX>_735[0][0])&&(e.clientX<_735[1][0])&&(e.clientY>_735[0][1])&&(e.clientY<_735[1][1])){
return true;
}
return false;
},onMouseOver:function(e){
},onMouseOut:function(e){
}});
dojo.dnd.dragManager=new dojo.dnd.HtmlDragManager();
(function(){
var d=document;
var dm=dojo.dnd.dragManager;
dojo.event.connect(d,"onkeydown",dm,"onKeyDown");
dojo.event.connect(d,"onmouseover",dm,"onMouseOver");
dojo.event.connect(d,"onmouseout",dm,"onMouseOut");
dojo.event.connect(d,"onmousedown",dm,"onMouseDown");
dojo.event.connect(d,"onmouseup",dm,"onMouseUp");
dojo.event.connect(window,"scrollBy",dm,"scrollBy");
})();
dojo.provide("dojo.dnd.HtmlDragAndDrop");
dojo.provide("dojo.dnd.HtmlDragSource");
dojo.provide("dojo.dnd.HtmlDropTarget");
dojo.provide("dojo.dnd.HtmlDragObject");
dojo.require("dojo.dnd.HtmlDragManager");
dojo.require("dojo.animation.*");
dojo.require("dojo.dom");
dojo.require("dojo.style");
dojo.require("dojo.html");
dojo.require("dojo.lang");
dojo.dnd.HtmlDragSource=function(node,type){
node=dojo.byId(node);
this.constrainToContainer=false;
if(node){
this.domNode=node;
this.dragObject=node;
dojo.dnd.DragSource.call(this);
this.type=type||this.domNode.nodeName.toLowerCase();
}
};
dojo.lang.extend(dojo.dnd.HtmlDragSource,{dragClass:"",onDragStart:function(){
var _73c=new dojo.dnd.HtmlDragObject(this.dragObject,this.type,this.dragClass);
if(this.constrainToContainer){
_73c.constrainTo(this.constrainingContainer);
}
return _73c;
},setDragHandle:function(node){
node=dojo.byId(node);
dojo.dnd.dragManager.unregisterDragSource(this);
this.domNode=node;
dojo.dnd.dragManager.registerDragSource(this);
},setDragTarget:function(node){
this.dragObject=node;
},constrainTo:function(_73f){
this.constrainToContainer=true;
if(_73f){
this.constrainingContainer=_73f;
}else{
this.constrainingContainer=this.domNode.parentNode;
}
}});
dojo.dnd.HtmlDragObject=function(node,type,_742){
this.domNode=dojo.byId(node);
this.type=type;
if(_742){
this.dragClass=_742;
}
this.constrainToContainer=false;
};
dojo.lang.extend(dojo.dnd.HtmlDragObject,{dragClass:"",opacity:0.5,disableX:false,disableY:false,onDragStart:function(e){
dojo.html.clearSelection();
this.scrollOffset={top:dojo.html.getScrollTop(),left:dojo.html.getScrollLeft()};
this.dragStartPosition={top:dojo.style.getAbsoluteY(this.domNode,true)+this.scrollOffset.top,left:dojo.style.getAbsoluteX(this.domNode,true)+this.scrollOffset.left};
this.dragOffset={top:this.dragStartPosition.top-e.clientY,left:this.dragStartPosition.left-e.clientX};
this.dragClone=this.domNode.cloneNode(true);
if((this.domNode.parentNode.nodeName.toLowerCase()=="body")||(dojo.style.getComputedStyle(this.domNode.parentNode,"position")=="static")){
this.parentPosition={top:0,left:0};
}else{
this.parentPosition={top:dojo.style.getAbsoluteY(this.domNode.parentNode,true),left:dojo.style.getAbsoluteX(this.domNode.parentNode,true)};
}
if(this.constrainToContainer){
this.constraints=this.getConstraints();
}
with(this.dragClone.style){
position="absolute";
top=this.dragOffset.top+e.clientY+"px";
left=this.dragOffset.left+e.clientX+"px";
}
if(this.dragClass){
dojo.html.addClass(this.dragClone,this.dragClass);
}
dojo.style.setOpacity(this.dragClone,this.opacity);
dojo.html.body().appendChild(this.dragClone);
},getConstraints:function(){
if(this.constrainingContainer.nodeName.toLowerCase()=="body"){
width=dojo.html.getViewportWidth();
height=dojo.html.getViewportHeight();
padLeft=0;
padTop=0;
}else{
width=dojo.style.getContentWidth(this.constrainingContainer);
height=dojo.style.getContentHeight(this.constrainingContainer);
padLeft=dojo.style.getPixelValue(this.constrainingContainer,"padding-left",true);
padTop=dojo.style.getPixelValue(this.constrainingContainer,"padding-top",true);
}
return {minX:padLeft,minY:padTop,maxX:padLeft+width-dojo.style.getOuterWidth(this.domNode),maxY:padTop+height-dojo.style.getOuterHeight(this.domNode)};
},updateDragOffset:function(){
var sTop=dojo.html.getScrollTop();
var _745=dojo.html.getScrollLeft();
if(sTop!=this.scrollOffset.top){
var diff=sTop-this.scrollOffset.top;
this.dragOffset.top+=diff;
this.scrollOffset.top=sTop;
}
},onDragMove:function(e){
this.updateDragOffset();
var x=this.dragOffset.left+e.clientX-this.parentPosition.left;
var y=this.dragOffset.top+e.clientY-this.parentPosition.top;
if(this.constrainToContainer){
if(x<this.constraints.minX){
x=this.constraints.minX;
}
if(y<this.constraints.minY){
y=this.constraints.minY;
}
if(x>this.constraints.maxX){
x=this.constraints.maxX;
}
if(y>this.constraints.maxY){
y=this.constraints.maxY;
}
}
if(!this.disableY){
this.dragClone.style.top=y+"px";
}
if(!this.disableX){
this.dragClone.style.left=x+"px";
}
},onDragEnd:function(e){
switch(e.dragStatus){
case "dropSuccess":
dojo.dom.removeNode(this.dragClone);
this.dragClone=null;
break;
case "dropFailure":
var _74b=[dojo.style.getAbsoluteX(this.dragClone),dojo.style.getAbsoluteY(this.dragClone)];
var _74c=[this.dragStartPosition.left+1,this.dragStartPosition.top+1];
var line=new dojo.math.curves.Line(_74b,_74c);
var anim=new dojo.animation.Animation(line,300,0,0);
var _74f=this;
dojo.event.connect(anim,"onAnimate",function(e){
_74f.dragClone.style.left=e.x+"px";
_74f.dragClone.style.top=e.y+"px";
});
dojo.event.connect(anim,"onEnd",function(e){
dojo.lang.setTimeout(dojo.dom.removeNode,200,_74f.dragClone);
});
anim.play();
break;
}
},constrainTo:function(_752){
this.constrainToContainer=true;
if(_752){
this.constrainingContainer=_752;
}else{
this.constrainingContainer=this.domNode.parentNode;
}
}});
dojo.dnd.HtmlDropTarget=function(node,_754){
if(arguments.length==0){
return;
}
node=dojo.byId(node);
this.domNode=node;
dojo.dnd.DropTarget.call(this);
this.acceptedTypes=_754||[];
};
dojo.inherits(dojo.dnd.HtmlDropTarget,dojo.dnd.DropTarget);
dojo.lang.extend(dojo.dnd.HtmlDropTarget,{onDragOver:function(e){
if(!this.accepts(e.dragObjects)){
return false;
}
this.childBoxes=[];
for(var i=0,child;i<this.domNode.childNodes.length;i++){
child=this.domNode.childNodes[i];
if(child.nodeType!=dojo.dom.ELEMENT_NODE){
continue;
}
var top=dojo.style.getAbsoluteY(child);
var _758=top+dojo.style.getInnerHeight(child);
var left=dojo.style.getAbsoluteX(child);
var _75a=left+dojo.style.getInnerWidth(child);
this.childBoxes.push({top:top,bottom:_758,left:left,right:_75a,node:child});
}
return true;
},_getNodeUnderMouse:function(e){
var _75c=e.pageX||e.clientX+dojo.html.body().scrollLeft;
var _75d=e.pageY||e.clientY+dojo.html.body().scrollTop;
for(var i=0,child;i<this.childBoxes.length;i++){
with(this.childBoxes[i]){
if(_75c>=left&&_75c<=right&&_75d>=top&&_75d<=bottom){
return i;
}
}
}
return -1;
},createDropIndicator:function(){
this.dropIndicator=document.createElement("div");
with(this.dropIndicator.style){
position="absolute";
zIndex=1;
borderTopWidth="1px";
borderTopColor="black";
borderTopStyle="solid";
width=dojo.style.getInnerWidth(this.domNode)+"px";
left=dojo.style.getAbsoluteX(this.domNode)+"px";
}
},onDragMove:function(e,_760){
var i=this._getNodeUnderMouse(e);
if(!this.dropIndicator){
this.createDropIndicator();
}
if(i<0){
if(this.childBoxes.length){
var _762=(dojo.html.gravity(this.childBoxes[0].node,e)&dojo.html.gravity.NORTH);
}else{
var _762=true;
}
}else{
var _763=this.childBoxes[i];
var _762=(dojo.html.gravity(_763.node,e)&dojo.html.gravity.NORTH);
}
this.placeIndicator(e,_760,i,_762);
if(!dojo.html.hasParent(this.dropIndicator)){
dojo.html.body().appendChild(this.dropIndicator);
}
},placeIndicator:function(e,_765,_766,_767){
with(this.dropIndicator.style){
if(_766<0){
if(this.childBoxes.length){
top=(_767?this.childBoxes[0].top:this.childBoxes[this.childBoxes.length-1].bottom)+"px";
}else{
top=dojo.style.getAbsoluteY(this.domNode)+"px";
}
}else{
var _768=this.childBoxes[_766];
top=(_767?_768.top:_768.bottom)+"px";
}
}
},onDragOut:function(e){
dojo.dom.removeNode(this.dropIndicator);
delete this.dropIndicator;
},onDrop:function(e){
this.onDragOut(e);
var i=this._getNodeUnderMouse(e);
if(i<0){
if(this.childBoxes.length){
if(dojo.html.gravity(this.childBoxes[0].node,e)&dojo.html.gravity.NORTH){
return this.insert(e,this.childBoxes[0].node,"before");
}else{
return this.insert(e,this.childBoxes[this.childBoxes.length-1].node,"after");
}
}
return this.insert(e,this.domNode,"append");
}
var _76c=this.childBoxes[i];
if(dojo.html.gravity(_76c.node,e)&dojo.html.gravity.NORTH){
return this.insert(e,_76c.node,"before");
}else{
return this.insert(e,_76c.node,"after");
}
},insert:function(e,_76e,_76f){
var node=e.dragObject.domNode;
if(_76f=="before"){
return dojo.html.insertBefore(node,_76e);
}else{
if(_76f=="after"){
return dojo.html.insertAfter(node,_76e);
}else{
if(_76f=="append"){
_76e.appendChild(node);
return true;
}
}
}
return false;
}});
dojo.hostenv.conditionalLoadModule({common:["dojo.dnd.DragAndDrop"],browser:["dojo.dnd.HtmlDragAndDrop"]});
dojo.hostenv.moduleLoaded("dojo.dnd.*");
dojo.provide("dojo.widget.Manager");
dojo.require("dojo.lang");
dojo.require("dojo.event.*");
dojo.widget.manager=new function(){
this.widgets=[];
this.widgetIds=[];
this.topWidgets={};
var _771={};
var _772=[];
this.getUniqueId=function(_773){
return _773+"_"+(_771[_773]!=undefined?++_771[_773]:_771[_773]=0);
};
this.add=function(_774){
dojo.profile.start("dojo.widget.manager.add");
this.widgets.push(_774);
if(_774.widgetId==""){
if(_774["id"]){
_774.widgetId=_774["id"];
}else{
if(_774.extraArgs["id"]){
_774.widgetId=_774.extraArgs["id"];
}else{
_774.widgetId=this.getUniqueId(_774.widgetType);
}
}
}
if(this.widgetIds[_774.widgetId]){
dojo.debug("widget ID collision on ID: "+_774.widgetId);
}
this.widgetIds[_774.widgetId]=_774;
dojo.profile.end("dojo.widget.manager.add");
};
this.destroyAll=function(){
for(var x=this.widgets.length-1;x>=0;x--){
try{
this.widgets[x].destroy(true);
delete this.widgets[x];
}
catch(e){
}
}
};
this.remove=function(_776){
var tw=this.widgets[_776].widgetId;
delete this.widgetIds[tw];
this.widgets.splice(_776,1);
};
this.removeById=function(id){
for(var i=0;i<this.widgets.length;i++){
if(this.widgets[i].widgetId==id){
this.remove(i);
break;
}
}
};
this.getWidgetById=function(id){
return this.widgetIds[id];
};
this.getWidgetsByType=function(type){
var lt=type.toLowerCase();
var ret=[];
dojo.lang.forEach(this.widgets,function(x){
if(x.widgetType.toLowerCase()==lt){
ret.push(x);
}
});
return ret;
};
this.getWidgetsOfType=function(id){
dj_deprecated("getWidgetsOfType is depecrecated, use getWidgetsByType");
return dojo.widget.manager.getWidgetsByType(id);
};
this.getWidgetsByFilter=function(_780){
var ret=[];
dojo.lang.forEach(this.widgets,function(x){
if(_780(x)){
ret.push(x);
}
});
return ret;
};
this.getAllWidgets=function(){
return this.widgets.concat();
};
this.byId=this.getWidgetById;
this.byType=this.getWidgetsByType;
this.byFilter=this.getWidgetsByFilter;
var _783={};
var _784=["dojo.widget","dojo.webui.widgets"];
for(var i=0;i<_784.length;i++){
_784[_784[i]]=true;
}
this.registerWidgetPackage=function(_786){
if(!_784[_786]){
_784[_786]=true;
_784.push(_786);
}
};
this.getWidgetPackageList=function(){
return dojo.lang.map(_784,function(elt){
return (elt!==true?elt:undefined);
});
};
this.getImplementation=function(_788,_789,_78a){
var impl=this.getImplementationName(_788);
if(impl){
var ret=new impl(_789);
return ret;
}
};
this.getImplementationName=function(_78d){
var _78e=_78d.toLowerCase();
var impl=_783[_78e];
if(impl){
return impl;
}
if(!_772.length){
for(var _790 in dojo.render){
if(dojo.render[_790]["capable"]===true){
var _791=dojo.render[_790].prefixes;
for(var i=0;i<_791.length;i++){
_772.push(_791[i].toLowerCase());
}
}
}
_772.push("");
}
for(var i=0;i<_784.length;i++){
var _793=dojo.evalObjPath(_784[i]);
if(!_793){
continue;
}
for(var j=0;j<_772.length;j++){
if(!_793[_772[j]]){
continue;
}
for(var _795 in _793[_772[j]]){
if(_795.toLowerCase()!=_78e){
continue;
}
_783[_78e]=_793[_772[j]][_795];
return _783[_78e];
}
}
for(var j=0;j<_772.length;j++){
for(var _795 in _793){
if(_795.toLowerCase()!=(_772[j]+_78e)){
continue;
}
_783[_78e]=_793[_795];
return _783[_78e];
}
}
}
throw new Error("Could not locate \""+_78d+"\" class");
};
this.resizing=false;
this.onResized=function(){
if(this.resizing){
return;
}
try{
this.resizing=true;
for(var id in this.topWidgets){
var _797=this.topWidgets[id];
if(_797.onResized){
_797.onResized();
}
}
}
finally{
this.resizing=false;
}
};
if(typeof window!="undefined"){
dojo.addOnLoad(this,"onResized");
dojo.event.connect(window,"onresize",this,"onResized");
}
};
dojo.widget.getUniqueId=function(){
return dojo.widget.manager.getUniqueId.apply(dojo.widget.manager,arguments);
};
dojo.widget.addWidget=function(){
return dojo.widget.manager.add.apply(dojo.widget.manager,arguments);
};
dojo.widget.destroyAllWidgets=function(){
return dojo.widget.manager.destroyAll.apply(dojo.widget.manager,arguments);
};
dojo.widget.removeWidget=function(){
return dojo.widget.manager.remove.apply(dojo.widget.manager,arguments);
};
dojo.widget.removeWidgetById=function(){
return dojo.widget.manager.removeById.apply(dojo.widget.manager,arguments);
};
dojo.widget.getWidgetById=function(){
return dojo.widget.manager.getWidgetById.apply(dojo.widget.manager,arguments);
};
dojo.widget.getWidgetsByType=function(){
return dojo.widget.manager.getWidgetsByType.apply(dojo.widget.manager,arguments);
};
dojo.widget.getWidgetsByFilter=function(){
return dojo.widget.manager.getWidgetsByFilter.apply(dojo.widget.manager,arguments);
};
dojo.widget.byId=function(){
return dojo.widget.manager.getWidgetById.apply(dojo.widget.manager,arguments);
};
dojo.widget.byType=function(){
return dojo.widget.manager.getWidgetsByType.apply(dojo.widget.manager,arguments);
};
dojo.widget.byFilter=function(){
return dojo.widget.manager.getWidgetsByFilter.apply(dojo.widget.manager,arguments);
};
dojo.widget.all=function(n){
var _799=dojo.widget.manager.getAllWidgets.apply(dojo.widget.manager,arguments);
if(arguments.length>0){
return _799[n];
}
return _799;
};
dojo.widget.registerWidgetPackage=function(){
return dojo.widget.manager.registerWidgetPackage.apply(dojo.widget.manager,arguments);
};
dojo.widget.getWidgetImplementation=function(){
return dojo.widget.manager.getImplementation.apply(dojo.widget.manager,arguments);
};
dojo.widget.getWidgetImplementationName=function(){
return dojo.widget.manager.getImplementationName.apply(dojo.widget.manager,arguments);
};
dojo.widget.widgets=dojo.widget.manager.widgets;
dojo.widget.widgetIds=dojo.widget.manager.widgetIds;
dojo.widget.root=dojo.widget.manager.root;
dojo.provide("dojo.widget.Widget");
dojo.provide("dojo.widget.tags");
dojo.require("dojo.lang");
dojo.require("dojo.widget.Manager");
dojo.require("dojo.event.*");
dojo.require("dojo.string");
dojo.widget.Widget=function(){
this.children=[];
this.extraArgs={};
};
dojo.lang.extend(dojo.widget.Widget,{parent:null,isTopLevel:false,isModal:false,isEnabled:true,isHidden:false,isContainer:false,widgetId:"",widgetType:"Widget",toString:function(){
return "[Widget "+this.widgetType+", "+(this.widgetId||"NO ID")+"]";
},repr:function(){
return this.toString();
},enable:function(){
this.isEnabled=true;
},disable:function(){
this.isEnabled=false;
},hide:function(){
this.isHidden=true;
},show:function(){
this.isHidden=false;
},create:function(args,_79b,_79c){
this.satisfyPropertySets(args,_79b,_79c);
this.mixInProperties(args,_79b,_79c);
this.postMixInProperties(args,_79b,_79c);
dojo.widget.manager.add(this);
this.buildRendering(args,_79b,_79c);
this.initialize(args,_79b,_79c);
this.postInitialize(args,_79b,_79c);
this.postCreate(args,_79b,_79c);
return this;
},destroy:function(_79d){
this.uninitialize();
this.destroyRendering(_79d);
dojo.widget.manager.removeById(this.widgetId);
},destroyChildren:function(_79e){
_79e=(!_79e)?function(){
return true;
}:_79e;
for(var x=0;x<this.children.length;x++){
var tc=this.children[x];
if((tc)&&(_79e(tc))){
tc.destroy();
}
}
},destroyChildrenOfType:function(type){
type=type.toLowerCase();
this.destroyChildren(function(item){
if(item.widgetType.toLowerCase()==type){
return true;
}else{
return false;
}
});
},getChildrenOfType:function(type,_7a4){
var ret=[];
type=type.toLowerCase();
for(var x=0;x<this.children.length;x++){
if(this.children[x].widgetType.toLowerCase()==type){
ret.push(this.children[x]);
}
if(_7a4){
ret=ret.concat(this.children[x].getChildrenOfType(type,_7a4));
}
}
return ret;
},getDescendants:function(){
var _7a7=[];
var _7a8=[this];
var elem;
while(elem=_7a8.pop()){
_7a7.push(elem);
dojo.lang.forEach(elem.children,function(elem){
_7a8.push(elem);
});
}
return _7a7;
},satisfyPropertySets:function(args){
return args;
},mixInProperties:function(args,frag){
if((args["fastMixIn"])||(frag["fastMixIn"])){
for(var x in args){
this[x]=args[x];
}
return;
}
var _7af;
var _7b0=dojo.widget.lcArgsCache[this.widgetType];
if(_7b0==null){
_7b0={};
for(var y in this){
_7b0[((new String(y)).toLowerCase())]=y;
}
dojo.widget.lcArgsCache[this.widgetType]=_7b0;
}
var _7b2={};
for(var x in args){
if(!this[x]){
var y=_7b0[(new String(x)).toLowerCase()];
if(y){
args[y]=args[x];
x=y;
}
}
if(_7b2[x]){
continue;
}
_7b2[x]=true;
if((typeof this[x])!=(typeof _7af)){
if(typeof args[x]!="string"){
this[x]=args[x];
}else{
if(dojo.lang.isString(this[x])){
this[x]=args[x];
}else{
if(dojo.lang.isNumber(this[x])){
this[x]=new Number(args[x]);
}else{
if(dojo.lang.isBoolean(this[x])){
this[x]=(args[x].toLowerCase()=="false")?false:true;
}else{
if(dojo.lang.isFunction(this[x])){
var tn=dojo.lang.nameAnonFunc(new Function(args[x]),this);
dojo.event.connect(this,x,this,tn);
}else{
if(dojo.lang.isArray(this[x])){
this[x]=args[x].split(";");
}else{
if(this[x] instanceof Date){
this[x]=new Date(Number(args[x]));
}else{
if(typeof this[x]=="object"){
var _7b4=args[x].split(";");
for(var y=0;y<_7b4.length;y++){
var si=_7b4[y].indexOf(":");
if((si!=-1)&&(_7b4[y].length>si)){
this[x][dojo.string.trim(_7b4[y].substr(0,si))]=_7b4[y].substr(si+1);
}
}
}else{
this[x]=args[x];
}
}
}
}
}
}
}
}
}else{
this.extraArgs[x]=args[x];
}
}
},postMixInProperties:function(){
},initialize:function(args,frag){
return false;
},postInitialize:function(args,frag){
return false;
},postCreate:function(args,frag){
return false;
},uninitialize:function(){
return false;
},buildRendering:function(){
dj_unimplemented("dojo.widget.Widget.buildRendering, on "+this.toString()+", ");
return false;
},destroyRendering:function(){
dj_unimplemented("dojo.widget.Widget.destroyRendering");
return false;
},cleanUp:function(){
dj_unimplemented("dojo.widget.Widget.cleanUp");
return false;
},addedTo:function(_7bc){
},addChild:function(_7bd){
dj_unimplemented("dojo.widget.Widget.addChild");
return false;
},addChildAtIndex:function(_7be,_7bf){
dj_unimplemented("dojo.widget.Widget.addChildAtIndex");
return false;
},removeChild:function(_7c0){
dj_unimplemented("dojo.widget.Widget.removeChild");
return false;
},removeChildAtIndex:function(_7c1){
dj_unimplemented("dojo.widget.Widget.removeChildAtIndex");
return false;
},resize:function(_7c2,_7c3){
this.setWidth(_7c2);
this.setHeight(_7c3);
},setWidth:function(_7c4){
if((typeof _7c4=="string")&&(_7c4.substr(-1)=="%")){
this.setPercentageWidth(_7c4);
}else{
this.setNativeWidth(_7c4);
}
},setHeight:function(_7c5){
if((typeof _7c5=="string")&&(_7c5.substr(-1)=="%")){
this.setPercentageHeight(_7c5);
}else{
this.setNativeHeight(_7c5);
}
},setPercentageHeight:function(_7c6){
return false;
},setNativeHeight:function(_7c7){
return false;
},setPercentageWidth:function(_7c8){
return false;
},setNativeWidth:function(_7c9){
return false;
},getDescendants:function(){
var _7ca=[];
var _7cb=[this];
var elem;
while(elem=_7cb.pop()){
_7ca.push(elem);
dojo.lang.forEach(elem.children,function(elem){
_7cb.push(elem);
});
}
return _7ca;
}});
dojo.widget.lcArgsCache={};
dojo.widget.tags={};
dojo.widget.tags.addParseTreeHandler=function(type){
var _7cf=type.toLowerCase();
this[_7cf]=function(_7d0,_7d1,_7d2,_7d3,_7d4){
return dojo.widget.buildWidgetFromParseTree(_7cf,_7d0,_7d1,_7d2,_7d3,_7d4);
};
};
dojo.widget.tags.addParseTreeHandler("dojo:widget");
dojo.widget.tags["dojo:propertyset"]=function(_7d5,_7d6,_7d7){
var _7d8=_7d6.parseProperties(_7d5["dojo:propertyset"]);
};
dojo.widget.tags["dojo:connect"]=function(_7d9,_7da,_7db){
var _7dc=_7da.parseProperties(_7d9["dojo:connect"]);
};
dojo.widget.buildWidgetFromParseTree=function(type,frag,_7df,_7e0,_7e1,_7e2){
var _7e3=type.split(":");
_7e3=(_7e3.length==2)?_7e3[1]:type;
var _7e4=_7e2||_7df.parseProperties(frag["dojo:"+_7e3]);
var _7e5=dojo.widget.manager.getImplementation(_7e3);
if(!_7e5){
throw new Error("cannot find \""+_7e3+"\" widget");
}else{
if(!_7e5.create){
throw new Error("\""+_7e3+"\" widget object does not appear to implement *Widget");
}
}
_7e4["dojoinsertionindex"]=_7e1;
var ret=_7e5.create(_7e4,frag,_7e0);
return ret;
};
dojo.provide("dojo.widget.Parse");
dojo.require("dojo.widget.Manager");
dojo.require("dojo.string");
dojo.require("dojo.dom");
dojo.widget.Parse=function(_7e7){
this.propertySetsList=[];
this.fragment=_7e7;
this.createComponents=function(_7e8,_7e9){
var _7ea=dojo.widget.tags;
var _7eb=[];
for(var item in _7e8){
var _7ed=false;
try{
if(_7e8[item]&&(_7e8[item]["tagName"])&&(_7e8[item]!=_7e8["nodeRef"])){
var tn=new String(_7e8[item]["tagName"]);
var tna=tn.split(";");
for(var x=0;x<tna.length;x++){
var ltn=dojo.string.trim(tna[x]).toLowerCase();
if(_7ea[ltn]){
_7ed=true;
_7e8[item].tagName=ltn;
var ret=_7ea[ltn](_7e8[item],this,_7e9,_7e8[item]["index"]);
_7eb.push(ret);
}else{
if((dojo.lang.isString(ltn))&&(ltn.substr(0,5)=="dojo:")){
dojo.debug("no tag handler registed for type: ",ltn);
}
}
}
}
}
catch(e){
dojo.debug("fragment creation error:",e);
}
if((!_7ed)&&(typeof _7e8[item]=="object")&&(_7e8[item]!=_7e8.nodeRef)&&(_7e8[item]!=_7e8["tagName"])){
_7eb.push(this.createComponents(_7e8[item],_7e9));
}
}
return _7eb;
};
this.parsePropertySets=function(_7f3){
return [];
var _7f4=[];
for(var item in _7f3){
if((_7f3[item]["tagName"]=="dojo:propertyset")){
_7f4.push(_7f3[item]);
}
}
this.propertySetsList.push(_7f4);
return _7f4;
};
this.parseProperties=function(_7f6){
var _7f7={};
for(var item in _7f6){
if((_7f6[item]==_7f6["tagName"])||(_7f6[item]==_7f6.nodeRef)){
}else{
if((_7f6[item]["tagName"])&&(dojo.widget.tags[_7f6[item].tagName.toLowerCase()])){
}else{
if((_7f6[item][0])&&(_7f6[item][0].value!="")){
try{
if(item.toLowerCase()=="dataprovider"){
var _7f9=this;
this.getDataProvider(_7f9,_7f6[item][0].value);
_7f7.dataProvider=this.dataProvider;
}
_7f7[item]=_7f6[item][0].value;
var _7fa=this.parseProperties(_7f6[item]);
for(var _7fb in _7fa){
_7f7[_7fb]=_7fa[_7fb];
}
}
catch(e){
dojo.debug(e);
}
}
}
}
}
return _7f7;
};
this.getDataProvider=function(_7fc,_7fd){
dojo.io.bind({url:_7fd,load:function(type,_7ff){
if(type=="load"){
_7fc.dataProvider=_7ff;
}
},mimetype:"text/javascript",sync:true});
};
this.getPropertySetById=function(_800){
for(var x=0;x<this.propertySetsList.length;x++){
if(_800==this.propertySetsList[x]["id"][0].value){
return this.propertySetsList[x];
}
}
return "";
};
this.getPropertySetsByType=function(_802){
var _803=[];
for(var x=0;x<this.propertySetsList.length;x++){
var cpl=this.propertySetsList[x];
var cpcc=cpl["componentClass"]||cpl["componentType"]||null;
if((cpcc)&&(propertySetId==cpcc[0].value)){
_803.push(cpl);
}
}
return _803;
};
this.getPropertySets=function(_807){
var ppl="dojo:propertyproviderlist";
var _809=[];
var _80a=_807["tagName"];
if(_807[ppl]){
var _80b=_807[ppl].value.split(" ");
for(propertySetId in _80b){
if((propertySetId.indexOf("..")==-1)&&(propertySetId.indexOf("://")==-1)){
var _80c=this.getPropertySetById(propertySetId);
if(_80c!=""){
_809.push(_80c);
}
}else{
}
}
}
return (this.getPropertySetsByType(_80a)).concat(_809);
};
this.createComponentFromScript=function(_80d,_80e,_80f){
var ltn="dojo:"+_80e.toLowerCase();
if(dojo.widget.tags[ltn]){
_80f.fastMixIn=true;
return [dojo.widget.tags[ltn](_80f,this,null,null,_80f)];
}else{
if(ltn.substr(0,5)=="dojo:"){
dojo.debug("no tag handler registed for type: ",ltn);
}
}
};
};
dojo.widget._parser_collection={"dojo":new dojo.widget.Parse()};
dojo.widget.getParser=function(name){
if(!name){
name="dojo";
}
if(!this._parser_collection[name]){
this._parser_collection[name]=new dojo.widget.Parse();
}
return this._parser_collection[name];
};
dojo.widget.createWidget=function(name,_813,_814,_815){
function fromScript(_816,name,_818){
var _819=name.toLowerCase();
var _81a="dojo:"+_819;
_818[_81a]={dojotype:[{value:_819}],nodeRef:_816,fastMixIn:true};
return dojo.widget.getParser().createComponentFromScript(_816,name,_818,true);
}
if(typeof name!="string"&&typeof _813=="string"){
dojo.deprecated("dojo.widget.createWidget","argument order is now of the form "+"dojo.widget.createWidget(NAME, [PROPERTIES, [REFERENCENODE, [POSITION]]])");
return fromScript(name,_813,_814);
}
_813=_813||{};
var _81b=false;
var tn=null;
var h=dojo.render.html.capable;
if(h){
tn=document.createElement("span");
}
if(!_814){
_81b=true;
_814=tn;
if(h){
dojo.html.body().appendChild(_814);
}
}else{
if(_815){
dojo.dom.insertAtPosition(tn,_814,_815);
}else{
tn=_814;
}
}
var _81e=fromScript(tn,name,_813);
if(!_81e[0]||typeof _81e[0].widgetType=="undefined"){
throw new Error("createWidget: Creation of \""+name+"\" widget failed.");
}
if(_81b){
if(_81e[0].domNode.parentNode){
_81e[0].domNode.parentNode.removeChild(_81e[0].domNode);
}
}
return _81e[0];
};
dojo.widget.fromScript=function(name,_820,_821,_822){
dojo.deprecated("dojo.widget.fromScript"," use "+"dojo.widget.createWidget instead");
return dojo.widget.createWidget(name,_820,_821,_822);
};
dojo.provide("dojo.widget.DomWidget");
dojo.require("dojo.event.*");
dojo.require("dojo.string");
dojo.require("dojo.widget.Widget");
dojo.require("dojo.dom");
dojo.require("dojo.xml.Parse");
dojo.require("dojo.uri.*");
dojo.widget._cssFiles={};
dojo.widget.defaultStrings={dojoRoot:dojo.hostenv.getBaseScriptUri(),baseScriptUri:dojo.hostenv.getBaseScriptUri()};
dojo.widget.buildFromTemplate=function(obj,_824,_825,_826){
var _827=_824||obj.templatePath;
var _828=_825||obj.templateCssPath;
if(!_828&&obj.templateCSSPath){
obj.templateCssPath=_828=obj.templateCSSPath;
obj.templateCSSPath=null;
dj_deprecated("templateCSSPath is deprecated, use templateCssPath");
}
if(_827&&!(_827 instanceof dojo.uri.Uri)){
_827=dojo.uri.dojoUri(_827);
dj_deprecated("templatePath should be of type dojo.uri.Uri");
}
if(_828&&!(_828 instanceof dojo.uri.Uri)){
_828=dojo.uri.dojoUri(_828);
dj_deprecated("templateCssPath should be of type dojo.uri.Uri");
}
var _829=dojo.widget.DomWidget.templates;
if(!obj["widgetType"]){
do{
var _82a="__dummyTemplate__"+dojo.widget.buildFromTemplate.dummyCount++;
}while(_829[_82a]);
obj.widgetType=_82a;
}
if((_828)&&(!dojo.widget._cssFiles[_828])){
dojo.html.insertCssFile(_828);
obj.templateCssPath=null;
dojo.widget._cssFiles[_828]=true;
}
var ts=_829[obj.widgetType];
if(!ts){
_829[obj.widgetType]={};
ts=_829[obj.widgetType];
}
if(!obj.templateString){
obj.templateString=_826||ts["string"];
}
if(!obj.templateNode){
obj.templateNode=ts["node"];
}
if((!obj.templateNode)&&(!obj.templateString)&&(_827)){
var _82c=dojo.hostenv.getText(_827);
if(_82c){
var _82d=_82c.match(/<body[^>]*>\s*([\s\S]+)\s*<\/body>/im);
if(_82d){
_82c=_82d[1];
}
}else{
_82c="";
}
obj.templateString=_82c;
ts.string=_82c;
}
if(!ts["string"]){
ts.string=obj.templateString;
}
};
dojo.widget.buildFromTemplate.dummyCount=0;
dojo.widget.attachProperties=["dojoAttachPoint","id"];
dojo.widget.eventAttachProperty="dojoAttachEvent";
dojo.widget.onBuildProperty="dojoOnBuild";
dojo.widget.attachTemplateNodes=function(_82e,_82f,_830){
var _831=dojo.dom.ELEMENT_NODE;
if(!_82e){
_82e=_82f.domNode;
}
if(_82e.nodeType!=_831){
return;
}
var _832=_82e.getElementsByTagName("*");
var _833=_82f;
for(var x=-1;x<_832.length;x++){
var _835=(x==-1)?_82e:_832[x];
var _836=[];
for(var y=0;y<this.attachProperties.length;y++){
var _838=_835.getAttribute(this.attachProperties[y]);
if(_838){
_836=_838.split(";");
for(var z=0;z<this.attachProperties.length;z++){
if((_82f[_836[z]])&&(dojo.lang.isArray(_82f[_836[z]]))){
_82f[_836[z]].push(_835);
}else{
_82f[_836[z]]=_835;
}
}
break;
}
}
var _83a=_835.getAttribute(this.templateProperty);
if(_83a){
_82f[_83a]=_835;
}
var _83b=_835.getAttribute(this.eventAttachProperty);
if(_83b){
var evts=_83b.split(";");
for(var y=0;y<evts.length;y++){
if((!evts[y])||(!evts[y].length)){
continue;
}
var _83d=null;
var tevt=dojo.string.trim(evts[y]);
if(evts[y].indexOf(":")>=0){
var _83f=tevt.split(":");
tevt=dojo.string.trim(_83f[0]);
_83d=dojo.string.trim(_83f[1]);
}
if(!_83d){
_83d=tevt;
}
var tf=function(){
var ntf=new String(_83d);
return function(evt){
if(_833[ntf]){
_833[ntf](dojo.event.browser.fixEvent(evt));
}
};
}();
dojo.event.browser.addListener(_835,tevt,tf,false,true);
}
}
for(var y=0;y<_830.length;y++){
var _843=_835.getAttribute(_830[y]);
if((_843)&&(_843.length)){
var _83d=null;
var _844=_830[y].substr(4);
_83d=dojo.string.trim(_843);
var tf=function(){
var ntf=new String(_83d);
return function(evt){
if(_833[ntf]){
_833[ntf](dojo.event.browser.fixEvent(evt));
}
};
}();
dojo.event.browser.addListener(_835,_844,tf,false,true);
}
}
var _847=_835.getAttribute(this.onBuildProperty);
if(_847){
eval("var node = baseNode; var widget = targetObj; "+_847);
}
_835.id="";
}
};
dojo.widget.getDojoEventsFromStr=function(str){
var re=/(dojoOn([a-z]+)(\s?))=/gi;
var evts=str?str.match(re)||[]:[];
var ret=[];
var lem={};
for(var x=0;x<evts.length;x++){
if(evts[x].legth<1){
continue;
}
var cm=evts[x].replace(/\s/,"");
cm=(cm.slice(0,cm.length-1));
if(!lem[cm]){
lem[cm]=true;
ret.push(cm);
}
}
return ret;
};
dojo.widget.buildAndAttachTemplate=function(obj,_850,_851,_852,_853){
this.buildFromTemplate(obj,_850,_851,_852);
var node=dojo.dom.createNodesFromText(obj.templateString,true)[0];
this.attachTemplateNodes(node,_853||obj,dojo.widget.getDojoEventsFromStr(_852));
return node;
};
dojo.widget.DomWidget=function(){
dojo.widget.Widget.call(this);
if((arguments.length>0)&&(typeof arguments[0]=="object")){
this.create(arguments[0]);
}
};
dojo.inherits(dojo.widget.DomWidget,dojo.widget.Widget);
dojo.lang.extend(dojo.widget.DomWidget,{templateNode:null,templateString:null,preventClobber:false,domNode:null,containerNode:null,addChild:function(_855,_856,pos,ref,_859){
if(!this.isContainer){
dojo.debug("dojo.widget.DomWidget.addChild() attempted on non-container widget");
return null;
}else{
this.addWidgetAsDirectChild(_855,_856,pos,ref,_859);
this.registerChild(_855,_859);
}
return _855;
},addWidgetAsDirectChild:function(_85a,_85b,pos,ref,_85e){
if((!this.containerNode)&&(!_85b)){
this.containerNode=this.domNode;
}
var cn=(_85b)?_85b:this.containerNode;
if(!pos){
pos="after";
}
if(!ref){
ref=cn.lastChild;
}
if(!_85e){
_85e=0;
}
_85a.domNode.setAttribute("dojoinsertionindex",_85e);
if(!ref){
cn.appendChild(_85a.domNode);
}else{
if(pos=="insertAtIndex"){
dojo.dom.insertAtIndex(_85a.domNode,ref.parentNode,_85e);
}else{
if((pos=="after")&&(ref===cn.lastChild)){
cn.appendChild(_85a.domNode);
}else{
dojo.dom.insertAtPosition(_85a.domNode,cn,pos);
}
}
}
},registerChild:function(_860,_861){
_860.dojoInsertionIndex=_861;
var idx=-1;
for(var i=0;i<this.children.length;i++){
if(this.children[i].dojoInsertionIndex<_861){
idx=i;
}
}
this.children.splice(idx+1,0,_860);
_860.parent=this;
_860.addedTo(this);
delete dojo.widget.manager.topWidgets[_860.widgetId];
},removeChild:function(_864){
for(var x=0;x<this.children.length;x++){
if(this.children[x]===_864){
this.children.splice(x,1);
break;
}
}
return _864;
},getFragNodeRef:function(frag){
if(!frag["dojo:"+this.widgetType.toLowerCase()]){
dojo.raise("Error: no frag for widget type "+this.widgetType+", id "+this.widgetId+" (maybe a widget has set it's type incorrectly)");
}
return (frag?frag["dojo:"+this.widgetType.toLowerCase()]["nodeRef"]:null);
},postInitialize:function(args,frag,_869){
var _86a=this.getFragNodeRef(frag);
if(_869&&(_869.snarfChildDomOutput||!_86a)){
_869.addWidgetAsDirectChild(this,"","insertAtIndex","",args["dojoinsertionindex"],_86a);
}else{
if(_86a){
if(this.domNode&&(this.domNode!==_86a)){
var _86b=_86a.parentNode.replaceChild(this.domNode,_86a);
}
}
}
if(_869){
_869.registerChild(this,args.dojoinsertionindex);
}else{
dojo.widget.manager.topWidgets[this.widgetId]=this;
}
if(this.isContainer){
var _86c=dojo.widget.getParser();
_86c.createComponents(frag,this);
}
},startResize:function(_86d){
dj_unimplemented("dojo.widget.DomWidget.startResize");
},updateResize:function(_86e){
dj_unimplemented("dojo.widget.DomWidget.updateResize");
},endResize:function(_86f){
dj_unimplemented("dojo.widget.DomWidget.endResize");
},buildRendering:function(args,frag){
var ts=dojo.widget.DomWidget.templates[this.widgetType];
if((!this.preventClobber)&&((this.templatePath)||(this.templateNode)||((this["templateString"])&&(this.templateString.length))||((typeof ts!="undefined")&&((ts["string"])||(ts["node"]))))){
this.buildFromTemplate(args,frag);
}else{
this.domNode=this.getFragNodeRef(frag);
}
this.fillInTemplate(args,frag);
},buildFromTemplate:function(args,frag){
var ts=dojo.widget.DomWidget.templates[this.widgetType];
if(ts){
if(!this.templateString.length){
this.templateString=ts["string"];
}
if(!this.templateNode){
this.templateNode=ts["node"];
}
}
var _876=false;
var node=null;
var tstr=new String(this.templateString);
if((!this.templateNode)&&(this.templateString)){
_876=this.templateString.match(/\$\{([^\}]+)\}/g);
if(_876){
var hash=this.strings||{};
for(var key in dojo.widget.defaultStrings){
if(dojo.lang.isUndefined(hash[key])){
hash[key]=dojo.widget.defaultStrings[key];
}
}
for(var i=0;i<_876.length;i++){
var key=_876[i];
key=key.substring(2,key.length-1);
var kval=(key.substring(0,5)=="this.")?this[key.substring(5)]:hash[key];
var _87d;
if((kval)||(dojo.lang.isString(kval))){
_87d=(dojo.lang.isFunction(kval))?kval.call(this,key,this.templateString):kval;
tstr=tstr.replace(_876[i],_87d);
}
}
}else{
this.templateNode=this.createNodesFromText(this.templateString,true)[0];
ts.node=this.templateNode;
}
}
if((!this.templateNode)&&(!_876)){
dojo.debug("weren't able to create template!");
return false;
}else{
if(!_876){
node=this.templateNode.cloneNode(true);
if(!node){
return false;
}
}else{
node=this.createNodesFromText(tstr,true)[0];
}
}
this.domNode=node;
this.attachTemplateNodes(this.domNode,this);
if(this.isContainer&&this.containerNode){
var src=this.getFragNodeRef(frag);
if(src){
dojo.dom.moveChildren(src,this.containerNode);
}
}
},attachTemplateNodes:function(_87f,_880){
if(!_880){
_880=this;
}
return dojo.widget.attachTemplateNodes(_87f,_880,dojo.widget.getDojoEventsFromStr(this.templateString));
},fillInTemplate:function(){
},destroyRendering:function(){
try{
var _881=this.domNode.parentNode.removeChild(this.domNode);
delete _881;
}
catch(e){
}
},cleanUp:function(){
},getContainerHeight:function(){
return dojo.html.getInnerHeight(this.domNode.parentNode);
},getContainerWidth:function(){
return dojo.html.getInnerWidth(this.domNode.parentNode);
},createNodesFromText:function(){
dj_unimplemented("dojo.widget.DomWidget.createNodesFromText");
}});
dojo.widget.DomWidget.templates={};
dojo.provide("dojo.widget.HtmlWidget");
dojo.require("dojo.widget.DomWidget");
dojo.require("dojo.html");
dojo.require("dojo.string");
dojo.widget.HtmlWidget=function(args){
dojo.widget.DomWidget.call(this);
};
dojo.inherits(dojo.widget.HtmlWidget,dojo.widget.DomWidget);
dojo.lang.extend(dojo.widget.HtmlWidget,{widgetType:"HtmlWidget",templateCssPath:null,templatePath:null,allowResizeX:true,allowResizeY:true,resizeGhost:null,initialResizeCoords:null,toggle:"plain",toggleDuration:150,animationInProgress:false,initialize:function(args,frag){
},postMixInProperties:function(args,frag){
dojo.lang.mixin(this,dojo.widget.HtmlWidget.Toggle[dojo.string.capitalize(this.toggle)]||dojo.widget.HtmlWidget.Toggle.Plain);
},getContainerHeight:function(){
dj_unimplemented("dojo.widget.HtmlWidget.getContainerHeight");
},getContainerWidth:function(){
return this.parent.domNode.offsetWidth;
},setNativeHeight:function(_887){
var ch=this.getContainerHeight();
},startResize:function(_889){
_889.offsetLeft=dojo.html.totalOffsetLeft(this.domNode);
_889.offsetTop=dojo.html.totalOffsetTop(this.domNode);
_889.innerWidth=dojo.html.getInnerWidth(this.domNode);
_889.innerHeight=dojo.html.getInnerHeight(this.domNode);
if(!this.resizeGhost){
this.resizeGhost=document.createElement("div");
var rg=this.resizeGhost;
rg.style.position="absolute";
rg.style.backgroundColor="white";
rg.style.border="1px solid black";
dojo.html.setOpacity(rg,0.3);
dojo.html.body().appendChild(rg);
}
with(this.resizeGhost.style){
left=_889.offsetLeft+"px";
top=_889.offsetTop+"px";
}
this.initialResizeCoords=_889;
this.resizeGhost.style.display="";
this.updateResize(_889,true);
},updateResize:function(_88b,_88c){
var dx=_88b.x-this.initialResizeCoords.x;
var dy=_88b.y-this.initialResizeCoords.y;
with(this.resizeGhost.style){
if((this.allowResizeX)||(_88c)){
width=this.initialResizeCoords.innerWidth+dx+"px";
}
if((this.allowResizeY)||(_88c)){
height=this.initialResizeCoords.innerHeight+dy+"px";
}
}
},endResize:function(_88f){
var dx=_88f.x-this.initialResizeCoords.x;
var dy=_88f.y-this.initialResizeCoords.y;
with(this.domNode.style){
if(this.allowResizeX){
width=this.initialResizeCoords.innerWidth+dx+"px";
}
if(this.allowResizeY){
height=this.initialResizeCoords.innerHeight+dy+"px";
}
}
this.resizeGhost.style.display="none";
},resizeSoon:function(){
if(this.isVisible()){
dojo.lang.setTimeout(this,this.onResized,0);
}
},createNodesFromText:function(txt,wrap){
return dojo.html.createNodesFromText(txt,wrap);
},_old_buildFromTemplate:dojo.widget.DomWidget.prototype.buildFromTemplate,buildFromTemplate:function(args,frag){
if(dojo.widget.DomWidget.templates[this.widgetType]){
var ot=dojo.widget.DomWidget.templates[this.widgetType];
dojo.widget.DomWidget.templates[this.widgetType]={};
}
if(args["templatecsspath"]){
args["templateCssPath"]=args["templatecsspath"];
}
if(args["templatepath"]){
args["templatePath"]=args["templatepath"];
}
dojo.widget.buildFromTemplate(this,args["templatePath"],args["templateCssPath"]);
this._old_buildFromTemplate(args,frag);
dojo.widget.DomWidget.templates[this.widgetType]=ot;
},destroyRendering:function(_897){
try{
var _898=this.domNode.parentNode.removeChild(this.domNode);
if(!_897){
dojo.event.browser.clean(_898);
}
delete _898;
}
catch(e){
}
},isVisible:function(){
return dojo.html.isVisible(this.domNode);
},doToggle:function(){
this.isVisible()?this.hide():this.show();
},show:function(){
this.animationInProgress=true;
this.showMe();
},onShow:function(){
this.animationInProgress=false;
},hide:function(){
this.animationInProgress=true;
this.hideMe();
},onHide:function(){
this.animationInProgress=false;
}});
dojo.widget.HtmlWidget.Toggle={};
dojo.widget.HtmlWidget.Toggle.Plain={showMe:function(){
dojo.html.show(this.domNode);
if(dojo.lang.isFunction(this.onShow)){
this.onShow();
}
},hideMe:function(){
dojo.html.hide(this.domNode);
if(dojo.lang.isFunction(this.onHide)){
this.onHide();
}
}};
dojo.widget.HtmlWidget.Toggle.Fade={showMe:function(){
dojo.fx.html.fadeShow(this.domNode,this.toggleDuration,dojo.lang.hitch(this,this.onShow));
},hideMe:function(){
dojo.fx.html.fadeHide(this.domNode,this.toggleDuration,dojo.lang.hitch(this,this.onHide));
}};
dojo.widget.HtmlWidget.Toggle.Wipe={showMe:function(){
dojo.fx.html.wipeIn(this.domNode,this.toggleDuration,dojo.lang.hitch(this,this.onShow));
},hideMe:function(){
dojo.fx.html.wipeOut(this.domNode,this.toggleDuration,dojo.lang.hitch(this,this.onHide));
}};
dojo.widget.HtmlWidget.Toggle.Explode={showMe:function(){
dojo.fx.html.explode(this.explodeSrc,this.domNode,this.toggleDuration,dojo.lang.hitch(this,this.onShow));
},hideMe:function(){
dojo.fx.html.implode(this.domNode,this.explodeSrc,this.toggleDuration,dojo.lang.hitch(this,this.onHide));
}};
dojo.hostenv.conditionalLoadModule({common:["dojo.xml.Parse","dojo.widget.Widget","dojo.widget.Parse","dojo.widget.Manager"],browser:["dojo.widget.DomWidget","dojo.widget.HtmlWidget"],svg:["dojo.widget.SvgWidget"]});
dojo.hostenv.moduleLoaded("dojo.widget.*");
dojo.provide("dojo.math.points");
dojo.require("dojo.math");
dojo.math.points={translate:function(a,b){
if(a.length!=b.length){
dojo.raise("dojo.math.translate: points not same size (a:["+a+"], b:["+b+"])");
}
var c=new Array(a.length);
for(var i=0;i<a.length;i++){
c[i]=a[i]+b[i];
}
return c;
},midpoint:function(a,b){
if(a.length!=b.length){
dojo.raise("dojo.math.midpoint: points not same size (a:["+a+"], b:["+b+"])");
}
var c=new Array(a.length);
for(var i=0;i<a.length;i++){
c[i]=(a[i]+b[i])/2;
}
return c;
},invert:function(a){
var b=new Array(a.length);
for(var i=0;i<a.length;i++){
b[i]=-a[i];
}
return b;
},distance:function(a,b){
return Math.sqrt(Math.pow(b[0]-a[0],2)+Math.pow(b[1]-a[1],2));
}};
dojo.hostenv.conditionalLoadModule({common:[["dojo.math",false,false],["dojo.math.curves",false,false],["dojo.math.points",false,false]]});
dojo.hostenv.moduleLoaded("dojo.math.*");

