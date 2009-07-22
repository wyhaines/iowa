/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 *
 * Modified September 2005 by Kirk Haines.  This is the UriClassifier that
 * was combined with the http parser in Mongrel under http11.  I have
 * separated it from the parser, renamed a few things to give it a more
 * general feel, and made some slight modifications for use with IOWA.
 *
 * This was originally taken from the Mongrel 0.3.13.3 version.
 */
#include "ruby.h"
#include "ext_help.h"
#include <assert.h>
#include <string.h>
#include <ctype.h>
#include "tst.h"

static VALUE mIowa;
static VALUE cClassifier;
static int id_handler_map;

#define TRIE_INCREASE 30

void Classifier_free(void *data) 
{
    if(data) {
      tst_cleanup((struct tst *)data);
    }
}

VALUE Classifier_alloc(VALUE klass)
{
    VALUE obj;
    struct tst *tst = tst_init(TRIE_INCREASE);
    assert(tst && "failed to initialize trie structure");

    obj = Data_Wrap_Struct(klass, NULL, Classifier_free, tst);

    return obj;
}

/**
 * call-seq:
 *    Classifier.new -> Classifier
 *
 * Initializes a new Classifier object that you can use to associate URI sequences
 * with objects.  You can actually use it with any string sequence and any objects,
 * but it's mostly used with URIs.
 *
 * It uses TST from http://www.octavian.org/cs/software.html to build an ternary search
 * trie to hold all of the URIs.  It uses this to do an initial search for the a URI
 * prefix, and then to break the URI into SCRIPT_NAME and PATH_INFO portions.  It actually
 * will do two searches most of the time in order to find the right handler for the
 * registered prefix portion.
 *
 */
VALUE Classifier_init(VALUE self)
{
  VALUE hash;

  // we create an internal hash to protect stuff from the GC
  hash = rb_hash_new();
  rb_ivar_set(self, id_handler_map, hash);

  return self;
}


/**
 * call-seq:
 *    uc.insert("/someuri", SampleHandler.new) -> nil
 *
 * Registers the SampleHandler (one for all requests) with the "/someuri".
 * When Classifier::resolve is called with "/someuri" it'll return
 * SampleHandler immediately.  When called with "/someuri/iwant" it'll also
 * return SomeHandler immediatly, with no additional searches, but it will
 * return path info with "/iwant".
 *
 * You actually can reuse this class to insert nearly anything and 
 * quickly resolve it.  This could be used for caching, fast mapping, etc.
 * The downside is it uses much more memory than a Hash, but it can be
 * a lot faster.  It's main advantage is that it works on prefixes, which
 * is damn hard to get right with a Hash.
 */
VALUE Classifier_insert(VALUE self, VALUE item, VALUE handler)
{
  int rc = 0;
  void *ptr = NULL;
  struct tst *tst = NULL;
  DATA_GET(self, struct tst, tst);

  rc = tst_insert((unsigned char *)StringValueCStr(item), (void *)handler , tst, 0, &ptr);

  if(rc == TST_DUPLICATE_KEY) {
    rb_raise(rb_eStandardError, "Handler already inserted with that name");
  } else if(rc == TST_ERROR) {
    rb_raise(rb_eStandardError, "Memory error inserting handler");
  } else if(rc == TST_NULL_KEY) {
    rb_raise(rb_eStandardError, "Value to insert was empty");
  }
  
  rb_hash_aset(rb_ivar_get(self, id_handler_map), item, handler);

  return Qnil;
}


/**
 * call-seq:
 *    uc.delete("/someuri")
 *
 * Yep, just removes this uri and it's handler from the trie.
 */
VALUE Classifier_delete(VALUE self, VALUE item)
{
  void *handler = NULL;
  struct tst *tst = NULL;
  DATA_GET(self, struct tst, tst);

  handler = tst_delete((unsigned char *)StringValueCStr(item), tst);

  if(handler) {
    rb_hash_delete(rb_ivar_get(self, id_handler_map), item);

    return (VALUE)handler;
  } else {
    return Qnil;
  }
}


/**
 * call-seq:
 *    uc.resolve("/someuri") -> "/someuri", "", handler
 *    uc.resolve("/someuri/pathinfo") -> "/someuri", "/pathinfo", handler
 *    uc.resolve("/notfound/orhere") -> nil, nil, nil
 *    uc.resolve("/") -> "/", "/", handler  # if uc.register("/", handler)
 *    uc.resolve("/path/from/root") -> "/", "/path/from/root", handler  # if uc.register("/", handler) 
 * 
 * Attempts to resolve either the whole URI or at the longest prefix, returning
 * the prefix (as script_info), path (as path_info), and registered handler
 * (usually an HttpHandler).  If it doesn't find a handler registered at the longest
 * match then it returns nil,nil,nil.
 *
 * Because the resolver uses a trie you are able to register a handler at *any* character
 * in the URI and it will be handled as long as it's the longest prefix.  So, if you 
 * registered handler #1 at "/something/lik", and #2 at "/something/like/that", then a
 * a search for "/something/like" would give you #1.  A search for "/something/like/that/too"
 * would give you #2.
 * 
 * This is very powerful since it means you can also attach handlers to parts of the ; 
 * (semi-colon) separated path params, any part of the path, use off chars, anything really.
 * It also means that it's very efficient to do this only taking as long as the URI has
 * characters.
 *
 * A slight modification to the CGI 1.2 standard is given for handlers registered to "/".
 * CGI expects all CGI scripts to be at some script path, so it doesn't really say anything
 * about a script that handles the root.  To make this work, the resolver will detect that
 * the requested handler is at "/", and return that for script_name, and then simply return
 * the full URI back as path_info.
 *
 * It expects strings with no embedded '\0' characters.  Don't try other string-like stuff yet.
 */
VALUE Classifier_resolve(VALUE self, VALUE item)
{
  void *handler = NULL;
  int pref_len = 0;
  struct tst *tst = NULL;
  VALUE result;
  unsigned char *item_str = NULL;

  DATA_GET(self, struct tst, tst);
  item_str = (unsigned char *)StringValueCStr(item);

  handler = tst_search(item_str, tst, &pref_len);

  result = rb_ary_new();

  if(handler) {
    rb_ary_push(result, rb_str_substr (item, 0, pref_len));
    if(pref_len == 1 && item_str[0] == '/') {
      rb_ary_push(result, item);
    } else {
      rb_ary_push(result, rb_str_substr(item, pref_len, RSTRING(item)->len));
    }
      
    rb_ary_push(result, (VALUE)handler);
  } else {
    rb_ary_push(result, Qnil);
    rb_ary_push(result, Qnil);
    rb_ary_push(result, Qnil);
  }

  return result;
}

VALUE Classifier_match(VALUE self, VALUE item)
{
  void *handler = NULL;
  int pref_len = 0;
  struct tst *tst = NULL;
  unsigned char *item_str = NULL;

  DATA_GET(self, struct tst, tst);
  item_str = (unsigned char *)StringValueCStr(item);

  handler = tst_search(item_str, tst, &pref_len);

  if(handler) {
    return (VALUE)handler;
  }

  return Qnil;
}


VALUE Classifier_handler_map(VALUE self) {
	VALUE hm;

 	hm = rb_ivar_get(self,id_handler_map);
	return rb_hash_dup(hm);
}

VALUE Classifier_keys(VALUE self) {
	int id_keys;
	id_keys = rb_intern("keys");
	return rb_funcall(rb_ivar_get(self,id_handler_map),id_keys,0);
}

VALUE Classifier_inspect(VALUE self) {
	int id_inspect;
	id_inspect = rb_intern("inspect");
	return rb_funcall(rb_ivar_get(self,id_handler_map),id_inspect,0);
}

void Init_classifier()
{

  mIowa = rb_define_module("Iowa");
  id_handler_map = rb_intern("@handler_map");

  cClassifier = rb_define_class_under(mIowa, "Classifier", rb_cObject);
  rb_define_alloc_func(cClassifier, Classifier_alloc);
  rb_define_method(cClassifier, "initialize", Classifier_init, 0);
  rb_define_method(cClassifier, "insert", Classifier_insert, 2);
  rb_define_method(cClassifier, "[]=", Classifier_insert, 2);
  rb_define_method(cClassifier, "delete", Classifier_delete, 1);
  rb_define_method(cClassifier, "resolve", Classifier_resolve, 1);
  rb_define_method(cClassifier, "[]", Classifier_match, 1);
	rb_define_method(cClassifier, "handler_map", Classifier_handler_map, 0);
	rb_define_method(cClassifier, "keys", Classifier_keys, 0);
	rb_define_method(cClassifier, "inspect", Classifier_inspect, 0);
}
 

