// Vocabulary desktop shell: one window showing the bundled offline page. No network, no accounts.
const { app, BrowserWindow, Menu, shell, session } = require('electron');
const path = require('path');
const { pathToFileURL } = require('url');

const PAGE = path.join(__dirname, 'app', 'index.html');
const PAGE_URL = pathToFileURL(PAGE).href;

app.setName('Vocabulary');
if (!app.commandLine.hasSwitch('user-data-dir')) app.setPath('userData', path.join(app.getPath('appData'), 'vocabulary'));

if (!app.requestSingleInstanceLock()) app.quit();
let win = null;
app.on('second-instance', () => { if (win) { if (win.isMinimized()) win.restore(); win.focus(); } });

app.whenReady().then(() => {
  // Offline by design: refuse every request that is not one of the app's own files.
  session.defaultSession.webRequest.onBeforeRequest((d, cb) => cb({ cancel: !d.url.startsWith('file://') && !d.url.startsWith('devtools://') }));
  Menu.setApplicationMenu(null);
  win = new BrowserWindow({
    width: 760, height: 900, minWidth: 360, minHeight: 480, backgroundColor: '#FFFFFF', title: 'Vocabulary',
    icon: path.join(__dirname, 'vocabulary.png'), autoHideMenuBar: true,
    webPreferences: { contextIsolation: true, nodeIntegration: false, sandbox: true, spellcheck: false },
  });
  win.webContents.on('will-navigate', (e, url) => { if (!url.startsWith(PAGE_URL)) e.preventDefault(); });
  win.webContents.setWindowOpenHandler(({ url }) => { if (/^https?:/.test(url)) shell.openExternal(url); return { action: 'deny' }; });
  win.loadFile(PAGE);
});
app.on('window-all-closed', () => app.quit());
