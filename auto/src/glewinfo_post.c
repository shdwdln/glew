}

#endif /* _WIN32 */

/* ------------------------------------------------------------------------ */

int main ()
{
  GLuint err;
  if (GL_TRUE == glewCreateContext())
  {
    fprintf(stderr, "Error: glewCreateContext failed\n");
    glewDestroyContext();
    return 1;
  }
  glewExperimental = GL_TRUE;
  err = glewInit();
  if (GLEW_OK != err)
  {
    fprintf(stderr, "Error [main]: glewInit failed: %s\n", glewGetErrorString(err));
    glewDestroyContext();
    return 1;
  }
#ifdef _WIN32
  f = fopen("glewinfo.txt", "w");
  if (f == NULL) f = stdout;
#else
  f = stdout;
#endif
  fprintf(f, "---------------------------\n");
  fprintf(f, "    GLEW Extension Info\n");
  fprintf(f, "---------------------------\n\n");
  fprintf(f, "Running on a %s from %s\n", 
	  glGetString(GL_RENDERER), glGetString(GL_VENDOR));
  fprintf(f, "OpenGL version %s is supported\n", glGetString(GL_VERSION));
  fprintf(f, "GLEW version %s is supported\n", glewGetString(GLEW_VERSION));
  glewInfo();
#ifdef _WIN32
  wglewInfo();
#else
  glxewInfo();
#endif
  if (f != stdout) fclose(f);
  glewDestroyContext();
  return 0;
}

/* ------------------------------------------------------------------------ */

#ifdef _WIN32

GLboolean glewCreateContext ()
{
  WNDCLASS wc;
  HWND wnd;
  HDC dc;
  PIXELFORMATDESCRIPTOR pfd;
  int pf;
  HGLRC rc;
  // register window class
  ZeroMemory(&wc, sizeof(WNDCLASS));
  wc.hInstance = GetModuleHandle(NULL);
  wc.lpfnWndProc = DefWindowProc;
  wc.lpszClassName = "GLEW";
  if (0 == RegisterClass(&wc)) return GL_TRUE;
  // create window
  wnd = CreateWindow("GLEW", "GLEW", 0, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, GetModuleHandle(NULL), NULL);
  if (NULL == wnd) return GL_TRUE;
  // get the device context
  dc = GetDC(wnd);
  if (NULL == dc) return GL_TRUE;
  // find pixel format
  ZeroMemory(&pfd, sizeof(PIXELFORMATDESCRIPTOR));
  pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
  pfd.nVersion = 1;
  pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL;
  pf = ChoosePixelFormat(dc, &pfd);
  if (pf == 0) return GL_TRUE;
  // set the pixel format for the dc
  if (FALSE == SetPixelFormat(dc, pf, &pfd)) return GL_TRUE;
  // create rendering context
  rc = wglCreateContext(dc);
  if (NULL == rc) return GL_TRUE;
  if (FALSE == wglMakeCurrent(dc, rc)) return GL_TRUE;
  return GL_FALSE;
}

void glewDestroyContext ()
{
  HWND wnd = FindWindow("GLEW", "GLEW");
  HGLRC rc = wglGetCurrentContext();
  HDC dc = wglGetCurrentDC();
  if (NULL != rc) wglMakeCurrent(NULL, NULL);
  if (NULL != rc) wglDeleteContext(wglGetCurrentContext());
  if (NULL != wnd && NULL != dc) ReleaseDC(wnd, dc);
  if (NULL != wnd) DestroyWindow(wnd);
  UnregisterClass("GLEW", GetModuleHandle(NULL));
}

#else

/* ------------------------------------------------------------------------ */

#  ifdef __APPLE__

GLboolean glewCreateContext ()
{
}

void glewDestroyContext ()
{
}

#  else /* __linux || __sgi */

/* ------------------------------------------------------------------------ */

GLboolean glewCreateContext ()
{
}

void glewDestroyContext ()
{
}

#  endif

#endif

