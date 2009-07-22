/*
 * JSON-RPC JavaScript client
 *
 * $Id: jsonrpc.js,v 1.3 2005/03/15 01:37:15 jamesgbritt Exp $
 *
 * Copyright (c) 2003-2004 Jan-Klaas Kollhof
 * Copyright (c) 2005 Michael Clark, Metaparadigm Pte Ltd
 *
 * This code is based on Jan-Klaas' JavaScript o lait library (jsolait).
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public (LGPL)
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details: http://www.gnu.org/
 *
 */

// TODO: Add async
// TODO: Add HTTP auth (user, password)

Object.prototype.toJSON = function Object_toJSON() {
    var v = [];
    for(attr in this) {
      if(this[attr] == null) v.push("\"" + attr + "\": null");
      else if(typeof this[attr] == "function"); // skip
      else v.push("\"" + attr + "\": " + this[attr].toJSON());
    }
    return "{" + v.join(", ") + "}";
}

String.prototype.toJSON = function String_toJSON()  {
    return "\"" + this.replace(/([\"\\])/g, "\\$1") + "\"";
}

Number.prototype.toJSON = function Number_toJSON() {
    return this.toString();
}

Boolean.prototype.toJSON = function Boolean_toJSON() {
    return this.toString();
}

Date.prototype.toJSON = function Date_toJSON() {
    this.valueOf().toString();
}

Array.prototype.toJSON = function Array_toJSON() {
    var v = [];
    for(var i=0; i<this.length; i++) {
      if(this[i] == null) v.push("null");
      else v.push(this[i].toJSON());
    }
    return "[" + v.join(", ") + "]";
}

JSONRpcClient = function JSONRpcClient_ctor(serverURL, objectID) {
    this.serverURL = serverURL;
    this.objectID = objectID;

    // Lazy initialization of the XMLHttpRequest singleton
    if(!JSONRpcClient.http)
      JSONRpcClient.http = JSONRpcClient.getHTTPRequest();

    // Add standard methods
    this.addMethods(["system.listMethods"]);

    // Query the methods on the server and add them to this object
    var m = this.sendRequest("system.listMethods", []);
    this.addMethods(m);
}

JSONRpcClient.Exception = function JSONRpcClient_Exception_ctor(code, msg) {
    this.code = code;
    this.msg = msg;
}

JSONRpcClient.Exception.prototype.toString =
function JSONRpcClient_Exception_toString(code, msg)  {
    return "JSONRpcClientException: " + this.msg;
}

JSONRpcClient.Method =
function JSONRpcClient_Method_ctor(client, methodName) {
    var fn=function()  {
      var args = [];
      for(var i=0;i<arguments.length;i++) {
          args.push(arguments[i]);
      }
      return fn.client.sendRequest.call(fn.client, fn.methodName, args);
    }
    fn.client = client;
    fn.methodName = methodName;
    return fn;
}

JSONRpcClient.prototype.addMethods =
function JSONRpcClient_addMethods(methodNames) {
    for(var i=0; i<methodNames.length; i++) {
    var obj = this;
    var names = methodNames[i].split(".");
    for(var n=0; n<names.length-1; n++){
      var name = names[n];
      if(obj[name]){
        obj = obj[name];
      } 
      else {
        obj[name]  = new Object();
        obj = obj[name];
      }
  }
  var name = names[names.length-1];
  if(!obj[name]){
      var method = new JSONRpcClient.Method(this, methodNames[i]);
      obj[name] = method;
   }
  }
}

JSONRpcClient.prototype.sendRequest =
function JSONRpcClient_sendRequest(methodName, args) {
    // Make request object
    var obj = {"method" : methodName, "params" : args};
    if (this.objectID) obj.objectID = this.objectID;

    // Marshall the request object to a JSON string
    var req_data = obj.toJSON();

    // Send the request
    JSONRpcClient.http.open("POST", this.serverURL, false); // no async
    // setRequestHeader is missing in Opera 8 Beta
    try {
      JSONRpcClient.http.setRequestHeader("Content-type", "text/plain");
    } 
    catch(e) {}
    JSONRpcClient.http.send(req_data);

    // Unmarshall the response
    // DEBUG
    try {
      eval("var obj = " + JSONRpcClient.http.responseText);
    }
    catch(e) {
      alert( e )            
      alert( JSONRpcClient.http.responseText )            
      obj.err = e.toString()
      }
    if( obj.error) {
      alert( JSONRpcClient.http.responseText )      
      throw new JSONRpcClient.Exception(obj.error.code, obj.error.msg);
     }
      var res = obj.result;

    // Handle CallableProxy
    if(res && res.objectID && res.JSONRPCType == "CallableReference")
      return new JSONRpcClient(this.serverURL, res.objectID);

    return res;
}

JSONRpcClient.getHTTPRequest = function JSONRpcClient_getHTTPRequest() {
    try { // to get the mozilla httprequest object
      return new XMLHttpRequest();
    } 
    catch(e) {}

    try { // to get MS HTTP request object
      return new ActiveXObject("Msxml2.XMLHTTP.4.0");
    } 
    catch(e) {}

    try { // to get MS HTTP request object
      return new ActiveXObject("Msxml2.XMLHTTP");
    } 
    catch(e) {}

    try {// to get the old MS HTTP request object
      return new ActiveXObject("microsoft.XMLHTTP"); 
    } 
    catch(e) {}

    throw new JSONRpcClient.Exception(0, "Can't create XMLHttpRequest object");
}
