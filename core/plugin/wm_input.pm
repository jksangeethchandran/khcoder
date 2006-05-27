package wm_input;
use strict;

#----------------------#
#   �ץ饰���������   #

sub plugin_config{
	return {
		name     => '�����ץ��������� - ̵����������ιԤ��б�',
		menu_cnf => 0,
		menu_grp => '������',
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	gui_window::wm_input->open; # GUI��ư
}

#-------------------------------#
#   GUI���Τ���Υ롼����   #

package gui_window::wm_input;
use base qw(gui_window);
use strict;
use Tk;

# Window�κ���
sub _new{
	my $self = shift;
	my $mw = $self->{win_obj};

	$mw->title(
		$self->gui_jchar('�����ץ��������ȡ�̵����������ιԤ��б���','euc')
	);

	# �ե졼��ν���
	my $lfra = $mw->LabFrame(
		-label       => 'Entry',
		-labelside   => 'acrosstop',
		-borderwidth => 2
	)->pack(
		-expand => 'yes',
		-fill   => 'both'
	);
	my $fra1 = $lfra->Frame()->pack(
		-anchor => 'c',
		-fill   => 'x',
		-expand => 'yes'
	);
	my $fra3 = $lfra->Frame()->pack(
		-anchor => 'c',
		-fill   => 'x',
		-expand => 'yes'
	);
	my $fra2 = $lfra->Frame()->pack(
		-anchor => 'c',
		-fill   => 'x',
		-expand => 'yes'
	);

	# ������ܤ�����
	$fra1->Label(
		-text => $self->gui_jchar('ʬ���оݥե����롧'),
		-font => "TKFN"
	)->pack(
		-side => 'left'
	);
	my $e1 = $fra1->Entry(
		-font => "TKFN",
		-background => 'white'
	)->pack(
		-side => 'right'
	);
	$fra1->Button(
		-text => $self->gui_jchar('����'),
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->_sansyo;});}
	)->pack(
		-side => 'right',
		-padx => 2
	);

	$fra3->Label(
		-text => $self->gui_jchar('ʬ���оݥե������ʸ�������ɡ�'),
		-font => "TKFN"
	)->pack(
		-side => 'left'
	);
	$self->{icode_menu} = gui_widget::optmenu->open(
		parent  => $fra3,
		pack    =>
			{
				-side => 'right',
				-padx => 2
			},
		options => 
			[
				[$self->gui_jchar('��ưȽ��')  => 0     ],
				[$self->gui_jchar('EUC')       => 'euc' ],
				[$self->gui_jchar('JIS')       => 'jis' ],
				[$self->gui_jchar('Shift-JIS') => 'sjis']
			],
		variable => \$self->{icode},
	);

	$fra2->Label(
		-text => $self->gui_jchar('�����ʥ��ˡ�'),
		-font => "TKFN"
	)->pack(
		-side => 'left'
	);
	my $e2 = $fra2->Entry(
		-font => "TKFN",
		-background => 'white'
	)->pack(
		-side => 'right',
		-pady => 2
	);

	# �ܥ����������
	$mw->Button(
		-text    => $self->gui_jchar('����󥻥�'),
		-font    => "TKFN",
		-width   => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(
		-side => 'right',
		-padx => 2
	);
	$mw->Button(
		-text    => 'OK',
		-width   => 8,
		-font    => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->_make_new;});}
	)->pack(
		-side => 'right'
	);

	# �������Entry�ˤ�����
	$e1->DropSite(
		-dropcommand => [\&Gui_DragDrop::get_filename_droped, $e1,],
		-droptypes   => ($^O eq 'MSWin32' ? 'Win32' : ['XDND', 'Sun'])
	);
	$mw->bind('Tk::Entry', '<Key-Delete>', \&gui_jchar::check_key_e_d);
	$e2->bind("<Key>",[\&gui_jchar::check_key_e,Ev('K'),\$e2]);
	$e2->bind("<Key-Return>",sub{$self->_make_new;});

	$self->{e1}  = $e1;
	$self->{e2}  = $e2;

	return $self;
}

# �ե����뻲�ȤΤ���Υ롼����
sub _sansyo{
	my $self = shift;
	my @types = (
		[ "text/html files",[qw/.txt .htm .html/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getOpenFile(
		-filetypes  => \@types,
		-title      => $self->gui_jchar('ʬ���оݥե���������򤷤Ƥ�������'),
		-initialdir => $::config_obj->cwd
	);
	if ($path){
		$::config_obj->os_path($path);
		$self->{e1}->delete('0','end');
		$self->{e1}->insert(0,$path);
	}
}

# �����ץ��������Ⱥ����Τ���Υ롼����
sub _make_new{
	my $self = shift;
	
	# ���Ԥˡ�---̵����������---�פ���������ʬ���ѥե���������
	use File::Basename;                                     # �ե�����̾�����
	my $new_file      = $self->gui_jg($self->{e1}->get);
	my $new_file_dir  = dirname($new_file);
	my $new_file_base = basename($new_file, qw/.txt .htm .html/);
	my $n = 0;
	while (-e $new_file){
		$new_file =
			$new_file_dir
			.'/'
			.$new_file_base
			."_ed$n.txt"
		;
		++$n;
	}
	open (ORGF,$self->gui_jg($self->{e1}->get)) or          # �ե��������
		gui_errormsg->open(
			type    => 'file',
			thefile => $self->gui_jg($self->{e1}->get)
		);
	open (NEWF,">$new_file") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => $new_file
		);
	while (<ORGF>){
		chomp;
		if ( length($_) ){
			print NEWF "$_\n";
		} else {
			print NEWF "---MISSING---\n";
		}
	}
	close (ORGF);
	close (NEWF);
	
	# ��������ʬ���ѥե������KH Coder����Ͽ
	my $new = kh_project->new(
		target  => $self->gui_jg($new_file),
		comment => $self->gui_jg($self->{e2}->get),
		icode   => $self->gui_jg($self->{icode}),
	) or return 0;
	kh_projects->read->add_new($new) or return 0;
	$self->close;
	$new->open or die;
	$::main_gui->close_all;
	$::main_gui->menu->refresh;
	$::main_gui->inner->refresh;
	
	# ��---̵����������---�פȤ������̵�뤹��褦������
	my $conf = kh_dictio->readin;
	$conf->words_mk( ['---MISSING---'] );
	$conf->words_st( ['---MISSING---'] );
	$conf->save;
	
	return 1;
}

sub win_name{
	return 'w_wm_input';
}

1;