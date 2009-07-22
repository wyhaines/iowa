/*****************************************************************************

$Id: http.h 2357 2006-04-22 19:49:00Z francis $

File:     http.h
Date:     21Apr06

Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
Gmail: garbagecat10

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*****************************************************************************/


#ifndef __HttpPersonality__H_
#define __HttpPersonality__H_


/**********************
class HttpConnection_t
**********************/

class HttpConnection_t
{
  public:
    HttpConnection_t();
    virtual ~HttpConnection_t();

		void ConsumeData (const char*, int);

    virtual void SendData (const char*, int);
    virtual void CloseConnection (bool after_writing);
    virtual void ProcessRequest();
		virtual void LogInfo (const char*, int);
		virtual void LogError (const char*, int);

  private:

		enum {
			BaseState,
			PreheaderState,
			HeaderState,
			ReadingContentState,
			DispatchState,
			EndState
		} ProtocolState;

		enum {
			MaxLeadingBlanks = 12,
			MaxHeaderLineLength = 8 * 1024,
			MaxContentLength = 20 * 1024 * 1024
		};
		int nLeadingBlanks;

		char HeaderLine [MaxHeaderLineLength];
		int HeaderLinePos;

		int ContentLength;
		int ContentPos;
		char *_Content;

		bool bRequestSeen;
		bool bContentLengthSeen;


	private:
		bool _InterpretHeaderLine (const char*);
		bool _InterpretRequest (const char*);
		bool _DetectVerbAndSetEnvString (const char*, int);
		void _SendError (int);
};

#endif // __HttpPersonality__H_




//////////////////////////////////////////////////
#if 0
#ifndef __HttpPersonality__H_
#define __HttpPersonality__H_


void http_event_callback (const char*, int, const char*, int);


/**********************
class HttpConnection_t
**********************/

class HttpConnection_t
{
	public:
		static void SetRequestCallback (void(*)(const char*, int, const char*, int));
		static void (*RequestCallback)(const char*, int, const char*, int);


	public:
		HttpConnection_t (string&);
		virtual ~HttpConnection_t();

		void ConsumeData (const char*, int);

	private:
		string Signifier;

		enum {
			BaseState,
			PreheaderState,
			HeaderState,
			ReadingContentState,
			DispatchState,
			EndState
		} ProtocolState;

		enum {
			MaxLeadingBlanks = 12,
			MaxHeaderLineLength = 8 * 1024,
			MaxContentLength = 20 * 1024 * 1024
		};
		int nLeadingBlanks;

		char HeaderLine [MaxHeaderLineLength];
		int HeaderLinePos;

		int ContentLength;
		int ContentPos;
		char *_Content;

		bool bRequestSeen;
		bool bContentLengthSeen;


	private:
		bool _InterpretHeaderLine (const char*);
		bool _InterpretRequest (const char*);
		bool _DetectVerbAndSetEnvString (const char*, int);
		void _SendError (int);
};


#endif // __HttpPersonality__H_
#endif
