/*
 * JSON-RPC JavaScript client
 *
 * $Id: jsonrpc_async.js,v 1.4 2005/03/15 02:29:22 jamesgbritt Exp $
 *
 * Copyright (c) 2003-2004 Jan-Klaas Kollhof
 * Copyright (c) 2005 Michael Clark, Metaparadigm Pte Ltd
 * Copyright (c) 2005 James Britt, Neurogami, LLC
 *
 * This code is based on Michael Clark's' version of Jan-Klaas' jsonrpc.js
 * file fom the JavaScript o lait library (jsolait).
 
 * The Clark version seemed easier to use the original Module-based
 * code, but did not do asyncronous requests.  The current version
 * is essentialy the same code, but with the async requests and callback 
 * hooks
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


/*******************************************************************
 ******************************************************************/
JSONRpcAsyncClient = function JSONRpcAsyncClient_ctor( serverURL, objectID ) {
    this.serverURL = serverURL;
    this.objectID = objectID;
    if( !JSONRpcAsyncClient.http )
      JSONRpcAsyncClient.http = JSONRpcAsyncClient.getHTTPRequest();
    this.addAsyncMethods( ["system.listMethods"] );
    var m = this.sendRequest( "system.listMethods", [] );
    this.addAsyncMethods( m );    

}

/*******************************************************************
 ******************************************************************/
JSONRpcAsyncClient.Exception = function JSONRpcAsyncClient_Exception_ctor(code, msg) {
    this.code = code;
    this.msg = msg;
}

/*******************************************************************
 ******************************************************************/
JSONRpcAsyncClient.Exception.prototype.toString =
function JSONRpcAsyncClient_Exception_toString(code, msg)  {
    return "JSONRpcAsyncClientException: " + this.msg;
}




JSONRpcAsyncClient.AsyncMethod =
function JSONRpcAsyncClient_Method_ctor( client, methodName ) {
  
    var fn=function()  {
      var args = [];
      var callback = arguments[0]
      for(var i=1; i< arguments.length;i++) {
          args.push(arguments[i]);
      }
      return fn.client.sendAsyncRequest.call( fn.client, fn.methodName, callback, args);
    }
    
    fn.client = client;
    fn.methodName = methodName;
    return fn;
}

 JSONRpcAsyncClient.prototype.addAsyncMethods =
function JSONRpcAsyncClient_addAsyncMethods(methodNames) {
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
      var method = new JSONRpcAsyncClient.AsyncMethod(this, methodNames[i]);
      obj[name] = method;
   }
  }
}


/*******************************************************************
 ******************************************************************/
// Async JSON-RPC call.  The tricky part may be catching the
// state change when the call is complete, and unmarshalling the
// response.
// Possibility: Have the user pass in a caqllback method; this method
// assumes it will get called with the unnarshalled response.
// When the reqadyState goes to 4, grab the JSON response, unmarshal,
// and invokve the callback

JSONRpcAsyncClient.prototype.sendAsyncRequest =
function JSONRpcAsyncClient_sendAsyncRequest( methodName, call_back, args ) {
    var obj = {"method" : methodName, "params" : args };
    if (this.objectID) obj.objectID = this.objectID;
    
    var req_data = obj.toJSON();
    
    var http = JSONRpcAsyncClient.getHTTPRequest();

    http.open("POST", this.serverURL, true); //  async

    try {
      http.setRequestHeader( "Content-type", "text/plain" );
    } 
    catch(e) {}


    http.onreadystatechange = function() {
      if ( http.readyState == 4 && http.status == 200) {
        try {
          s  = "var obj = " + http.responseText 
          eval( s );
        }
        catch( e ) {
          var e_msg = "onreadystatechange Error: " + e + "\nresponseText: " + http.responseText  
          obj.err = e.toString()
        }
        if( obj.error ) {
          throw new JSONRpcAsyncClient.Exception( obj.error.code, obj.error.msg );
        }
        return call_back( obj.result );
      }
      else {
        }
    }

    http.send( req_data );

}


/*******************************************************************
 ******************************************************************/
JSONRpcAsyncClient.prototype.sendRequest =

 function JSONRpcAsyncClient_sendRequest(methodName, args) {
    // Make request object
    var obj = {"method" : methodName, "params" : args};
    if (this.objectID) obj.objectID = this.objectID;

    // Marshall the request object to a JSON string
    var req_data = obj.toJSON();

    // Send the request
    JSONRpcAsyncClient.http.open("POST", this.serverURL, false); // no async
    // setRequestHeader is missing in Opera 8 Beta
    try {
      JSONRpcAsyncClient.http.setRequestHeader("Content-type", "text/plain");
    } 
    catch(e) {}
    JSONRpcAsyncClient.http.send(req_data);

    // Unmarshall the response

    try {
      eval("var obj = " + JSONRpcAsyncClient.http.responseText);
    }
    catch(e) {
      alert( "sendRequest error: " + e + "\nresponseText: " + JSONRpcAsyncClient.http.responseText )            
      obj.err = e.toString()
    }
    if( obj.error) {
      alert( JSONRpcAsyncClient.http.responseText )      
      throw new JSONRpcAsyncClient.Exception(obj.error.code, obj.error.msg);
     }
      var res = obj.result;

    // Handle CallableProxy
    if(res && res.objectID && res.JSONRPCType == "CallableReference")
      return new JSONRpcAsyncClient(this.serverURL, res.objectID);

    return res;
}

/*******************************************************************
 ******************************************************************/
JSONRpcAsyncClient.getHTTPRequest = function JSONRpcAsyncClient_getHTTPRequest() {

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

    throw new JSONRpcAsyncClient.Exception( 0, "Can't create XMLHttpRequest object");
}


