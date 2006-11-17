//-----------------------------------------------------------------------------
// wxD - wxObject.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - wxObject.cs
//
/// The wxObject wrapper class.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id$
//-----------------------------------------------------------------------------

module wx.wxObject;
public import wx.common;

		//! \cond EXTERN
		extern (C) {
		alias void function(IntPtr ptr) Virtual_Dispose;
		}
	
		static extern (C) string wxObject_GetTypeName(IntPtr obj);
		static extern (C) void   wxObject_dtor(IntPtr self);
		//! \endcond

		//---------------------------------------------------------------------
		// this is for Locale gettext support...
		
		//! \cond EXTERN
		static extern (C) string wxGetTranslation_func(string str);
		//! \endcond
		
		public static string GetTranslation(string str)
		{
			return wxGetTranslation_func(str).dup;
		}

		// in wxWidgets it is a c/c++ macro
				
		public static string _(string str)
		{
			return wxGetTranslation_func(str).dup;
		}

		//---------------------------------------------------------------------
/+
	template findObject(class T)
	T find(IntPtr ptr){
		Object o = wxObject.FindObject(ptr);
		if (o) return cast(T)o;
		else new T(ptr);
	}
+/
	//! \brief This is the root class of all wxWidgets classes.
	//! It declares a virtual destructor which ensures that destructors get
	//! called for all derived class objects where necessary.
	
	//! wxObject is the hub of a dynamic object creation scheme, enabling a
	//! program to create instances of a class only knowing its string class
	//! name, and to query the class hierarchy.
	public class wxObject : IDisposable
	{
		// Reference to the associated C++ object
		public IntPtr wxobj = IntPtr.init;

		// Hashtable to associate C++ objects with D references
		private static wxObject[IntPtr] objects;
		
		// memOwn is true when we create a new instance with the wrapper ctor
		// or if a call to a wrapper function returns new c++ instance.
		// Otherwise the created c++ object won't be deleted by the Dispose member.
		protected bool memOwn = false;
		
		//---------------------------------------------------------------------

		public this(IntPtr wxobj)
		{
		//	lock(typeof(wxObject)) {
				this.wxobj = wxobj;

				if (wxobj == IntPtr.init) {
					throw new NullReferenceException("Unable to create instance of " ~ this.toString());
				}

				AddObject(this);
		//	}
		}

		private this(IntPtr wxobj,bool memOwn)
		{
			this(wxobj);
			this.memOwn = memOwn;
		}

		//---------------------------------------------------------------------

		public static IntPtr SafePtr(wxObject obj)
		{
			return obj ? obj.wxobj : IntPtr.init;
		}
		
		//---------------------------------------------------------------------

		private static string GetTypeName(IntPtr wxobj)
		{
			return wxObject_GetTypeName(wxobj).dup;
		}

		public string GetTypeName()
		{
			return wxObject_GetTypeName(wxobj).dup;
		}

		//---------------------------------------------------------------------

		// Registers an wxObject, so that it can be referenced using a C++ object
		// pointer.
        
		private static void AddObject(wxObject obj)
		{
			if (obj.wxobj != IntPtr.init) {
				objects[obj.wxobj] = obj;
			}
		}
	
		//---------------------------------------------------------------------

		// Locates the registered object that references the given C++ object
		// pointer.
		//
		// If the pointer is not found, a reference to the object is created 
		// using type.

		alias static wxObject function(IntPtr wxobj) newfunc;

		public static wxObject FindObject(IntPtr ptr, newfunc New)
		{
			if (ptr == IntPtr.init) {
				return null;
			}

			wxObject o = FindObject(ptr);

			// If the object wasn't found, create it
		//	if (type != null && (o == null || o.GetType() != type)) {
		//		o = (wxObject)Activator.CreateInstance(type, new object[]{ptr});
		//	}
			if (o is null) {
				o = New(ptr);
			}

			return o;
		}
	
		// Locates the registered object that references the given C++ object
		// pointer.

		public static wxObject FindObject(IntPtr ptr)
		{
			if (ptr != IntPtr.init) {
				wxObject *o = ptr in objects;
				if (o) return *o;
			}

			return null;
		}
		
		//---------------------------------------------------------------------

		// Removes a registered object.
		// returns true if the object is found in the
		// Hashtable and is removed (for Dispose)

		public static bool RemoveObject(IntPtr ptr)
		{
			bool retval = false;

			if (ptr != IntPtr.init)
			{
				if(ptr in objects) {
					objects.remove(ptr);
					retval = true;
				}
			}
			
			return retval;
		}
		
		//---------------------------------------------------------------------
		
		// called when an c++ (wx)wxObject dtor gets invoked
		static extern(C) private void VirtualDispose(IntPtr ptr)
		{
			FindObject(ptr).realVirtualDispose();
		}

		private void realVirtualDispose()
		{
			RemoveObject(wxobj);
			wxobj = IntPtr.init;
		}

		protected void dtor() { wxObject_dtor(wxobj); }

		public /+virtual+/ void Dispose()
		{
			if (wxobj != IntPtr.init)
			{
			//	bool still_there = RemoveObject(wxobj);

			//	lock (typeof (wxObject)) {
					if (memOwn /*&& still_there*/)
					{
						dtor();
					}
			//	}
				
				RemoveObject(wxobj);
				wxobj = IntPtr.init;
			//	memOwn = false;
			}
			//GC.SuppressFinalize(this);
		}
		
		~this()
		{
			Dispose();
		}

		protected bool disposed() { return wxobj==IntPtr.init; }
	}

