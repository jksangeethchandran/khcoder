package gui_window::cod_cls;
use base qw(gui_window);

use strict;


#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt(kh_msg->get('win_titile'))); # �����ǥ��󥰡����饹����ʬ�ϡ����ץ����

	my $lf = $win->LabFrame(
		-label       => 'Options',
		-labelside   => 'acrosstop',
		-borderwidth => 2
	)->pack(
		-fill   => 'both',
		-expand => 1
	);

	# �롼�롦�ե�����
	my %pack0 = (
		-anchor => 'w',
		#-padx => 2,
		#-pady => 2,
		-fill => 'x',
		-expand => 0,
	);
	$self->{codf_obj} = gui_widget::codf->open(
		parent  => $lf,
		pack    => \%pack0,
		command => sub{$self->read_cfile;},
	);
	
	# �����ǥ���ñ��
	my $f1 = $lf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 4
	);
	$f1->Label(
		-text => kh_msg->get('gui_window::cod_corresp->coding_unit'), # �����ǥ���ñ�̡�
		-font => "TKFN",
	)->pack(-side => 'left');
	my %pack1 = (
		-anchor => 'w',
		-padx => 2,
		-pady => 2,
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f1,
		pack   => \%pack1,
	);

	# ����������
	$lf->Label(
		-text => kh_msg->get('gui_window::cod_corresp->select_codes'), # ����������
		-font => "TKFN",
	)->pack(-anchor => 'nw', -padx => 2, -pady => 0);

	my $f2 = $lf->Frame()->pack(
		-fill   => 'both',
		-expand => 1,
		-padx   => 2,
		-pady   => 2
	);

	$f2->Label(
		-text => '    ',
		-font => "TKFN"
	)->pack(
		-anchor => 'w',
		-side   => 'left',
	);

	my $f2_1 = $f2->Frame(
		-borderwidth        => 2,
		-relief             => 'sunken',
	)->pack(
			-anchor => 'w',
			-side   => 'left',
			-pady   => 2,
			-padx   => 2,
			-fill   => 'both',
			-expand => 1
	);

	# ������������HList
	$self->{hlist} = $f2_1->Scrolled(
		'HList',
		-scrollbars         => 'osoe',
		#-relief             => 'sunken',
		-font               => 'TKFN',
		-selectmode         => 'none',
		-indicator => 0,
		-highlightthickness => 0,
		-columns            => 1,
		-borderwidth        => 0,
		-height             => 12,
	)->pack(
		-fill   => 'both',
		-expand => 1
	);

	my $f2_2 = $f2->Frame()->pack(
		-fill   => 'x',
		-expand => 0,
		-side   => 'left'
	);
	$f2_2->Button(
		-text => kh_msg->gget('all'), # ���٤�
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{$self->select_all;}
	)->pack(-pady => 3);
	$f2_2->Button(
		-text => kh_msg->gget('clear'), # ���ꥢ
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{$self->select_none;}
	)->pack();

	$lf->Label(
		-text => kh_msg->get('gui_window::cod_corresp->sel3'), # �����������ɤ�3�İʾ����򤷤Ʋ�������
		-font => "TKFN",
	)->pack(
		-anchor => 'w',
		-padx   => 4,
		-pady   => 2,
	);

	# ���饹����ʬ�ϤΥ��ץ����
	$self->{cls_obj} = gui_widget::r_cls->open(
		parent       => $lf,
		command      => sub{ $self->_calc; },
		pack    => { -anchor   => 'w'},
	);

	# �ե���ȥ�����
	$self->{font_obj} = gui_widget::r_font->open(
		parent    => $lf,
		command   => sub{ $self->_calc; },
		pack      => { -anchor   => 'w' },
		show_bold => 0,
		plot_size => 'Auto',
	);

	#SCREEN Plugin
	use screen_code::cluster;
	&screen_code::cluster::add_menu($self,$lf,1);
	#SCREEN Plugin

	$win->Checkbutton(
			-text     => kh_msg->gget('r_dont_close'), # �¹Ի��ˤ��β��̤��Ĥ��ʤ�
			-variable => \$self->{check_rm_open},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	# OK������󥻥�
	my $f3 = $win->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);

	$f3->Button(
		-text => kh_msg->gget('cancel'), # ����󥻥�
		-font => "TKFN",
		-width => 8,
		-command => sub{$self->withd;}
	)->pack(-side => 'right',-padx => 2);

	$self->{ok_btn} = $f3->Button(
		-text => kh_msg->gget('ok'),
		-width => 8,
		-font => "TKFN",
		-state => 'disable',
		-command => sub{$self->_calc;}
	)->pack(-side => 'right');
	$self->{ok_btn}->focus;

	$self->read_cfile;

	return $self;
}

# �����ǥ��󥰥롼�롦�ե�������ɤ߹���
sub read_cfile{
	my $self = shift;
	
	$self->{hlist}->delete('all');
	
	unless (-e $self->cfile ){
		return 0;
	}
	
	my $cod_obj = kh_cod::func->read_file($self->cfile);
	
	unless (eval(@{$cod_obj->codes})){
		return 0;
	}

	my $left = $self->{hlist}->ItemStyle('window',-anchor => 'w');

	my $row = 0;
	$self->{checks} = undef;
	foreach my $i (@{$cod_obj->codes}){
		
		$self->{checks}[$row]{check} = 1;
		$self->{checks}[$row]{name}  = $i->name;
		
		my $c = $self->{hlist}->Checkbutton(
			-text     => $i->name,
			-variable => \$self->{checks}[$row]{check},
			-command  => sub{ $self->check_selected_num;},
			-anchor => 'w',
		);
		
		$self->{checks}[$row]{widget} = $c;
		
		$self->{hlist}->add($row,-at => "$row");
		$self->{hlist}->itemCreate(
			$row,0,
			-itemtype  => 'window',
			-style     => $left,
			-widget    => $c,
		);
		++$row;
	}
	
	$self->check_selected_num;
	
	return $self;
}

sub start_raise{
	my $self = shift;
	
	# ������������ɤ߼��
	my %selection = ();
	foreach my $i (@{$self->{checks}}){
		if ($i->{check}){
			$selection{$i->{name}} = 1;
		} else {
			$selection{$i->{name}} = -1;
		}
	}
	
	# �롼��ե��������ɤ߹���
	$self->read_cfile;
	
	# �����Ŭ��
	foreach my $i (@{$self->{checks}}){
		if ($selection{$i->{name}} == 1 || $selection{$i->{name}} == 0){
			$i->{check} = 1;
		} else {
			$i->{check} = 0;
		}
	}
	
	$self->{hlist}->update;
	return 1;
}


# �����ɤ�3�İʾ����򤵤�Ƥ��뤫�����å�
sub check_selected_num{
	my $self = shift;
	
	my $selected_num = 0;
	foreach my $i (@{$self->{checks}}){
		++$selected_num if $i->{check};
	}
	
	if ($selected_num >= 3){
		$self->{ok_btn}->configure(-state => 'normal');
	} else {
		$self->{ok_btn}->configure(-state => 'disable');
	}
	return $self;
}

# ���٤�����
sub select_all{
	my $self = shift;
	foreach my $i (@{$self->{checks}}){
		$i->{widget}->select;
	}
	$self->check_selected_num;
	return $self;
}

# ���ꥢ
sub select_none{
	my $self = shift;
	foreach my $i (@{$self->{checks}}){
		$i->{widget}->deselect;
	}
	$self->check_selected_num;
	return $self;
}

# �ץ��åȺ�����ɽ��
sub _calc{
	my $self = shift;

	my @selected = ();
	foreach my $i (@{$self->{checks}}){
		push @selected, $i->{name} if $i->{check};
	}
	my $selected_num = @selected;
	if ($selected_num < 3){
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => kh_msg->get('gui_window::cod_corresp->sel3'), # '�����ɤ�3�İʾ����򤷤Ƥ���������'
		);
		return 0;
	}

	my $wait_window = gui_wait->start;

	# �ǡ�������
	my $r_command;
	unless ( $r_command =  kh_cod::func->read_file($self->cfile)->out2r_selected($self->tani,\@selected) ){
		gui_errormsg->open(
			type   => 'msg',
			window => \$self->win_obj,
			msg    => kh_msg->get('gui_window::cod_corresp->er_zero'),
		);
		#$self->close();
		$wait_window->end(no_dialog => 1);
		return 0;
	}
	
	# ���饹����ʬ�ϼ¹ԤΤ����R���ޥ��
	$r_command .= "\n";
	$r_command .= "d <- t(d)\n";
	$r_command .= "row.names(d) <- c(";
	foreach my $i (@{$self->{checks}}){
		my $name = $i->{name};
		if (index($name,'��') == 0){
			substr($name, 0, 2) = '';
		}
		elsif (index($name,'*') == 0){
			substr($name, 0, 1) = ''
		}
		$r_command .= '"'.$name.'",'
			if $i->{check}
		;
	}
	chop $r_command;
	$r_command .= ")\n";
	$r_command .= "# END: DATA\n";

	my $plot = &gui_window::word_cls::make_plot(
		$self->{cls_obj}->params,
		font_size      => $self->{font_obj}->font_size,
		font_bold      => $self->{font_obj}->check_bold_text,
		plot_size      => $self->{font_obj}->plot_size,
		r_command      => $r_command,
		plotwin_name   => 'cod_cls',
		data_number    => $selected_num,
	);

	$wait_window->end(no_dialog => 1);
	return 0 unless $plot;
	
	unless ( $self->{check_rm_open} ){
		$self->withd;
	}

}

sub start{
	my $self = shift;

	# Window���Ĥ���ݤΥХ����
	$self->win_obj->bind(
		'<Control-Key-q>',
		sub{ $self->withd; }
	);
	$self->win_obj->bind(
		'<Key-Escape>',
		sub{ $self->withd; }
	);
	$self->win_obj->protocol('WM_DELETE_WINDOW', sub{ $self->withd; });
}

#--------------#
#   ��������   #

sub cfile{
	my $self = shift;
	return $self->{codf_obj}->cfile;
}
sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub win_name{
	return 'w_cod_cls';
}
1;