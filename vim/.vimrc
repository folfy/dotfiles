" vim:foldmethod=marker:foldlevel=0:foldcolumn=2
set nocompatible
scriptencoding utf-8

" runtime load {{{1
" workarround to use correct ctags
let $PATH = '/homes/ffritzer/usr/bin:' . $PATH

let noload = ( $NoVimRecover == "TRUE" )
if ! noload
	runtime ftplugin/man.vim

	" handled by vimplug:
	" syntax enable
	" filetype plugin indent on

	" vim-plug {{{2
	" bootstrap
	if empty(glob('~/.vim/autoload/plug.vim'))
		" required to also work inside thales-network
		silent !mkdir -p ~/.vim/autoload ~/.vim/vim-plug
		silent !mkdir ~/.vim/undo ~/.vim/backup/ ~/.vim/swap
		silent !git clone --depth=1
			\ https://github.com/junegunn/vim-plug.git ~/.vim/vim-plug
		silent !cp ~/.vim/vim-plug/plug.vim ~/.vim/autoload
		silent !rm -rf ~/.vim/vim-plug/plug.vim
		" silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		" \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		qall!
	endif
	if empty(glob('~/.vim/plugged'))
		autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	endif

	function! Cond(cond, ...)
		let opts = get(a:000, 0, {})
		return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
	endfunction

	call plug#begin('~/.vim/plugged')
	Plug 'mileszs/ack.vim'
	Plug 'vim-scripts/CmdlineComplete'
	Plug 'wincent/command-t'
	Plug 'tpope/vim-fugitive'
	Plug 'airblade/vim-gitgutter', Cond(v:version >= 703)
	Plug 'sjl/gundo.vim'
	Plug 'tomasr/molokai'
	Plug 'scrooloose/nerdtree', Cond(v:version >= 702, { 'on': 'NERDTreeToggle' })
	Plug 'python-mode/python-mode', { 'branch': 'develop', 'for': 'python' }
	Plug 'chrisbra/Recover.vim'
	Plug 'vim-scripts/ReplaceWithRegister'
	Plug 'ervandew/supertab'
	Plug 'zirrostig/vim-schlepp'
	Plug 'tpope/vim-surround'
	Plug 'vim-syntastic/syntastic', Cond(v:version >= 701)
	Plug 'godlygeek/tabular'
	Plug 'majutsushi/tagbar', Cond(v:version >= 701)
	Plug 'mbbill/undotree'
	Plug 'tpope/vim-unimpaired'
	Plug 'vim-airline/vim-airline'
	Plug 'benknoble/vim-auto-origami', Cond(exists('v:true'))
	Plug 'ConradIrwin/vim-bracketed-paste'
	Plug 'altercation/vim-colors-solarized'
	Plug 'tpope/vim-commentary'
	Plug 'ehamberg/vim-cute-python', Cond(!exists('degraded'), { 'branch' : 'moresymbols' })
	Plug 'junegunn/vim-easy-align'
	Plug 'easymotion/vim-easymotion'
	Plug 'tpope/vim-eunuch'
	Plug 'michaeljsmith/vim-indent-object'
	Plug 'farmergreg/vim-lastplace'
	Plug 'tbastos/vim-lua'
	Plug 'tpope/vim-repeat'
	Plug 'sbdchd/vim-shebang'
	Plug 'roxma/vim-tmux-clipboard'
	Plug 'tmux-plugins/vim-tmux-focus-events'
	Plug 'ntpeters/vim-better-whitespace'
	call plug#end()
endif

" vim settings {{{1
" limited terminal mode {{{2
if exists('degraded')
	set encoding=iso-8859-1
else
	set encoding=utf-8
endif
" }}}
set fileformats=unix,dos
set shiftwidth=4
set tabstop=4
set softtabstop=4
set noexpandtab
set autoindent
set hidden " allow modified buffers to be hidden
set mouse=a
if has('nvim')
	let g:loaded_python_provider = 1
	let g:loaded_python3_provider = 1
	tnoremap <Esc> <C-\><C-n>
else
	let g:pymode_python = 'python3'
	" seems to make problems with vim8, ubuntu in vimdiff?
	" set shellcmdflag=-ic "default to interactive shell (bashrc/aliases)
	set ttymouse=xterm2
endif
" highlight search; immediate search
set hlsearch
set incsearch
" if uppercase-char in search = case-sensitive
set ignorecase
set smartcase
" set timeout (commands; ESC-Key)
set timeoutlen=1000
set ttimeoutlen=50
set foldenable
" background refresh interval for some plugins, etc.
set updatetime=500
" set foldmethod=syntax "indent, marker, manual
set modelines=2
" set autocomplete, show unfinished commands
set wildmode=longest,list,full
set wildmenu
set showcmd
" don't save local / global vars in session
set ssop-=options

let mapleader=','

" vim general / directories {{{1
if has('win32')
	let vimdir='Z:/.vim'
	set tags=Z:\bin\.tags,./.tags
else
	let vimdir=expand('~/.vim')
	set tags=~/bin/.tags,$datap/.tags,./.tags
endif

" Backup - Enable backup-file and undo-file in ~/.vim/backup
" there seems to be an issue, let *dir is not working properly
set backup
let &backupdir = vimdir . "/backup//,."
let &dir = vimdir . "/swap//,."
if v:version > 702
	let &undodir = vimdir . "/undo//"
	set undofile
	" set undolevels=1000
	" set undoreload=10000
endif

" keep multiple backups if <=100kb
au BufWritePre * call s:backup_ext()
function! s:backup_ext()
	if getfsize(expand(@%)) <= 100000
		let &backupext = '~' . strftime("%y%m%d") "optional: _%h%M
	else
		let &backupext = '~'
	endif
endfunction

" Viminfo:
" % -> save/restore buffer list
" ' -> file marks saved
" / -> search history saved
" : -> command-line history saved
" < -> max register size (lines)
" s -> max register size (kb)
" h -> disable 'hlsearch' loading viminfo
" n -> viminfo file-path
if has('nvim')
	let &viminfo = '%,''10,/50,:50,<1000,s100,h'
else
	let &viminfo = '%,''10,/50,:50,<1000,s100,h,n' . vimdir . '/.viminfo'
endif
set history=50

" vim autocmds {{{1
set autoread " update buffer if file modified (unmodified buffer)
augroup vimrc_gen
	" autocheck if files has changed on disk
	autocmd CursorHold * if expand('%') !=# '[Command Line]' | checktime | endif
	" Have Vim jump to the last position when reopening a file
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	" Highlight matching parenthesis
	autocmd VimEnter * DoMatchParen
	" auto-hide folding column
	if exists('v:true')
		autocmd CursorHold,BufWinEnter,WinEnter * AutoOrigamiFoldColumn
	endif
augroup END

" file specifics {{{1
let g:surround_{char2nr('q')} = "\\\"\r\\\""

autocmd FileType sh setlocal commentstring=#\ %s
autocmd FileType vim setlocal commentstring=\"\ %s
autocmd FileType chill setlocal tabstop=8
augroup filetypedetect
	au! BufRead,BufNewFile *.chinc	setfiletype chill
	au! BufRead,BufNewFile *.chinc	matchdelete(w:hl80)
	au! BufRead,BufNewFile *.chinc	matchdelete(w:hl100)
	au! BufRead,BufNewFile *.chinc	matchadd('ColorColumn', '~')
augroup END
let g:vimsyn_folding='af'

" elektra-log {{{2
command! ELlog call ELLogMode()

function! ELLogMode()
	setlocal foldmethod=expr
	setlocal foldexpr=GetELLogFold(v:lnum)
	setlocal list lcs=tab:\|\ 
endfunction

function! GetELLogFold(lnum)
	if getline(a:lnum) =~? '\v^\s'
		return '1'
	endif
	return '0'
endfunction

" PLUGINS {{{1
" tmux {{{2
let g:autoswap_detect_tmux = 1

" if exists('$TMUX') || exists('$LC_TMUX')
" 	let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
" 	let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
" else
" 	let &t_SI = "\<Esc>]50;CursorShape=1\x7"
" 	let &t_EI = "\<Esc>]50;CursorShape=0\x7"
" endif

" Syntastic {{{2
nmap <leader>s :SyntasticCheck<CR>
let g:syntastic_aways_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" airline {{{2
if ! noload
	set laststatus=2
	if has('gui_running') "&& ! has ('win32')
		let g:airline_powerline_fonts=1
	endif
	let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
	let g:airline#extensions#whitespace#mixed_indent_algo = 2
	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#tab_nr_type = 2
	let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
	let g:airline#extensions#tabline#fnamemod = ':t' " ':~:.'
	let g:airline#extensions#tabline#show_splits = 0
	let g:airline#extensions#tabline#buffers_label = 'b'
	let g:airline#extensions#tabline#tabs_label = 't'
	let g:airline#extensions#tabline#show_close_button = 0
	let g:airline#extensions#tabline#buffer_min_count = 2
	let g:airline#extensions#tabline#buffer_nr_show = 1
	let g:airline#extensions#tabline#buffer_nr_format = '%s '
	nmap <leader>1 :buffer 1<CR>
	nmap <leader>2 :buffer 2<CR>
	nmap <leader>3 :buffer 3<CR>
	nmap <leader>4 :buffer 4<CR>
	nmap <leader>5 :buffer 5<CR>
	nmap <leader>6 :buffer 6<CR>
	nmap <leader>7 :buffer 7<CR>
	nmap <leader>8 :buffer 8<CR>
	nmap <leader>9 :buffer 9<CR>
	set noshowmode " hide mode, show in airline
	let g:airline_mode_map = {
		\ '__' : '-',
		\ 'n'  : 'N',
		\ 'i'  : 'I',
		\ 'R'  : 'R',
		\ 'c'  : 'C',
		\ 'v'  : 'V',
		\ 'V'  : 'V',
		\ '' : 'V',
		\ 's'  : 'S',
		\ 'S'  : 'S',
		\ '' : 'S',
		\ }

	" Human readable line number with thousands separator, remove file position (%)
	function! MyLineNumber()
		return substitute(line('.'), '\d\@<=\(\(\d\{3\}\)\+\)$', ',&', 'g'). '/'.
		  \    substitute(line('$'), '\d\@<=\(\(\d\{3\}\)\+\)$', ',&', 'g')
	endfunction
	call airline#parts#define('linenr', {'function': 'MyLineNumber', 'accents': 'bold'})

	if !exists("g:airline_powerline_fonts")
		if !exists('g:airline_symbols')
			let g:airline_symbols = {}
		endif
		let g:airline_symbols.maxlinenr = ''
	endif
	let g:airline_section_z = airline#section#create(['linenr', '%{g:airline_symbols.maxlinenr}', ':%3v'])
endif

" SuperTab {{{2
let g:SuperTabClosePreviewOnPopupClose = 1
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestHighlight = 1
let g:SuperTabLongestEnhanced = 1
set completeopt=longest,menu

" Toolbars / Easyalign {{{2
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nnoremap <F6> :UndotreeToggle<CR>
let g:undotree_WindowLayout = 2
nnoremap <F7> :GundoToggle<CR>
let g:gundo_width = 35
let g:gundo_preview_bottom = 1
let g:gundo_preview_height = 10
map <F8> :NERDTreeToggle<CR>
nmap <F9> :TagbarToggle<CR>

" easymotion {{{2
if v:version >= 704
	map <SPACE> <Plug>(easymotion-prefix)
	nmap <C-f> <Plug>(easymotion-bd-w)
	map f <Plug>(easymotion-f)
	map F <Plug>(easymotion-F)
	map t <Plug>(easymotion-t)
	map T <Plug>(easymotion-T)

	let g:EasyMotion_smartcase = 1
	let g:EasyMoition_enter_jump_first = 1
	let g:EasyMoition_space_jump_first = 1
	let g:EasyMotion_keys = "asdghklqwertzuiopyxcvbnmfj"
endif

" SHORTCUTS {{{1
" general shortcuts {{{2
cmap w!! %!sudo tee > /dev/null %
cnoreabbrev wd w<bar>bd
nmap <leader>q :confirm quitall<CR>
map <M-Space> <ESC>
inoremap <expr> <C-L> &insertmode ? '<C-L>' : '<Esc>'

" select commands
vmap <C-c> "+yi
vmap <C-x> "+c
nmap <leader><C-a> ggyG<C-o><C-o>

nnoremap K :Man <cword>

nmap <leader>a= :Tabularize /=<CR>
vmap <leader>a= :Tabularize /=<CR>
nmap <leader>a: :Tabularize /:\zs<CR>
vmap <leader>a: :Tabularize /:\zs<CR>
nmap <leader>a\| :Tabularize /\|<CR>
vmap <leader>a\| :Tabularize /\|<CR>
set pastetoggle=<F10>

"paste-mode
set cursorcolumn
nmap <leader>h :set cursorcolumn!<CR>
nmap <leader>H :set cursorline!<CR>
nmap <leader>P :call ToggleTabs('simple')<CR>
nmap <leader>p :call ToggleTabs('')<CR>
" nmap <leader>p :set list!<CR>
nmap <leader>l :call NumberToggle()<CR>
nmap <leader>L :set relativenumber!<CR>
" toggle foldingColumn
nmap <leader>f :let &l:foldcolumn = &l:foldcolumn ? 0 : 2<CR>
nmap <leader>i :set paste! <CR>
nmap <leader>w :set wrap!<CR>
nmap <leader>W :set wrapscan!<CR>
nmap <leader>S :set scrollbind!<CR>
set scrolloff=5
nmap <leader>z :let &scrolloff=5-&scrolloff<CR>
nmap <leader>F :FixWhitespace<CR>
nmap <leader>c :setlocal spell! spelllang=en_us<CR>
" spellcheck - move with ]s and [s, fix z=, add zg
nmap <leader>D :DiffSaved<CR>
nmap <leader>d "=strftime("%d.%m.%Y")<CR>P
nmap <F3> "=strftime("%d.%m.%Y")<CR>P
imap <F3> <C-R>=strftime("%d.%m.%Y")<CR>
" reload file
nmap <leader>e :edit<CR>
nmap <leader>C :edit $HOME/.vimrc<CR>
" insert line without entering insert-mode
nmap <CR> o<Esc>k

nmap <C-l> gcl
vmap <C-l> gc

" buffers / windows / movement {{{2
nmap <silent> <C-k> :wincmd k<CR>
nmap <silent> <C-j> :wincmd j<CR>
nmap <silent> <C-h> :wincmd h<CR>
nmap <silent> <C-l> :wincmd l<CR>

map <silent> <C-t>k :tabrewind<CR>
map <silent> <C-t>j :tablast<CR>
map <silent> <C-t>h :tabprevious<CR>
map <silent> <C-t>l :tabnext<CR>
map <silent> <C-t>n :tabnew<CR>
map <silent> <C-t>c :tabclose<CR>

nmap <C-p> :bp<CR>
nmap <C-n> :bn<CR>
nmap <C-e> :bd<CR>
nmap <C-b> :ls<cr>:b<space>

" move in insert-mode (by char and word)
inoremap <C-w> <C-o>w
inoremap <C-b> <C-o>b
inoremap <C-W> <C-o>W
inoremap <C-B> <C-o>B
inoremap <C-h> <C-o>h
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-l> <C-o>l

" visual block dragging (replaces dragvisuals)
vmap <up>    <Plug>SchleppUp
vmap <down>  <Plug>SchleppDown
vmap <left>  <Plug>SchleppLeft
vmap <right> <Plug>SchleppRight
vmap D       <Plug>SchleppDup

" Remove any introduced trailing whitespace after moving...
let g:DVB_TrimWS = 1

" Theme / syntax-highlighting {{{1
nmap <leader>t :call ThemeToggle("molokai")<CR>
nmap <leader>T :call ThemeToggle("desert")<CR>
nmap <leader><C-t> :call ThemeToggle("solarized")<CR>
function! ThemeToggle(new)
	if ( g:colors_name != a:new )
		execute 'colorscheme' a:new
	else
		if ( g:solarized_termcolors == 16 && a:new == 'solarized' )
			let g:solarized_termcolors = 256
			let g:airline_powerline_fonts=1
		else
			let g:solarized_termcolors = 16
			let g:airline_powerline_fonts=0
		endif
		set background=dark
		colorscheme solarized
	endif
	" echom 'Changed colorscheme to ' . g:colors_name
endfunction

set t_ut= " bugfix - disable clearing using BG-color
" set lazyredraw          " redraw only when we need to.
set background=dark
if exists('degraded')
	colorscheme molokai
else
	colorscheme solarized
endif

" line numbers {{{1
" replace with numbers.vim (but not today, requires vim >=7.3)
set number
if v:version >= 703
	set relativenumber

	nnoremap <leader>n :set relativenumber!<cr>

	augroup vimrc
		autocmd FocusLost * :set norelativenumber
		autocmd FocusGained * :set relativenumber
		autocmd InsertEnter * :set norelativenumber
		autocmd InsertLeave * :set relativenumber
	augroup END

	highlight ColorColumn ctermbg=magenta
	let w:hl80=matchadd('ColorColumn', '\%81v', 100)
	let w:hl100=matchadd('ColorColumn', '\%101v', 100)
endif

function! NumberToggle()
	set number!
	if(v:version >= 703)
		let &relativenumber=&number
	endif
endfunc

" tab-space / slash-blash tools {{{1
:command! -nargs=1 -range SuperRetab <line1>,<line2>s/\v%(^ *)@<= {<args>}/\t/g

:command! -nargs=1 -range Tab2Space execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . <args> . ')'
:command! -nargs=0 -range Space2Tab execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')'

function! ReTab()
	:%Tab2Space 8
	:%Space2Tab
endfunction
function! FixTab()
	:%Tab2Space 4
	:%Space2Tab
endfunction
com! Retab call ReTab()
com! Fixtab call FixTab()
nmap <leader>r :Retab<CR>
nmap <leader>R :Fixtab<CR>

" Backslash toggle
function! ToggleSlash(independent) range
	let from = ''
	for lnum in range(a:firstline, a:lastline)
		let line = getline(lnum)
		let first = matchstr(line, '[/\\]')
		if !empty(first)
			if a:independent || empty(from)
				let from = first
			endif
			let opposite = (from == '/' ? '\' : '/')
			call setline(lnum, substitute(line, from, opposite, 'g'))
		endif
	endfor
endfunction
command! -bang -range ToggleSlash <line1>,<line2>call ToggleSlash(<bang>1)
noremap <silent> <leader><Bslash> :ToggleSlash<CR>

function! ToggleTabs(simple)
	set list!
	if v:version < 703 || a:simple == 'simple'
		set listchars=tab:>\ ,
		if a:simple == 'simple'
			set list
		endif
	else
		set listchars=tab:»\ ,eol:¬,trail:.,nbsp:~
	endif
endfunc

if v:version >= 703
	set listchars=tab:»\ ,eol:¬,trail:.,nbsp:~
else
	call ToggleTabs('simple')
endif

" unkown (F5) {{{1
:nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

" diff saved {{{1
function! s:DiffWithSaved()
	let filetype=&ft
	diffthis
	vnew | r # | normal! 1Gdd
	diffthis
	exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" GUI {{{1
if has('gui_running')
	if has("win32")
		" set runtimepath+=Z:\.vim
		" source Z:\.vimrc

		set guifont=DejaVu_Sans_Mono_for_Powerline:h8:cANSI:qDRAFT,Consolas:h8:cANSI:qDRAFT
		nmap <leader><M-c> :e $HOME/_vimrc<ENTER>
		nmap <leader>C :e Z:\.vimrc<ENTER>
	else
		" fallback doesn't work on GTK...
		set guifont=Hack\ 8,Monospace\ 8
	endif
	set guioptions=agit "remove menu+tool bar, scrollbar L+R - org. agimrLtT
	nnoremap <leader>M :if &go=~#'m'<Bar>set go-=mrLT<Bar>else<Bar>set go+=mrLT<Bar>endif<CR>
endif

" Vimrc {{{1
augroup myvimrc
	autocmd!
	autocmd BufWritePost $MYVIMRC source $MYVIMRC
	if has('nvim')
		autocmd BufWritePost $HOME/.vimrc source $HOME/.vimrc
	endif
augroup END
