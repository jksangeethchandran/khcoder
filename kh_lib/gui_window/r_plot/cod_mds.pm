package gui_window::r_plot::cod_mds;
use base qw(gui_window::r_plot);

sub option1_options{
	return [
		kh_msg->get('gui_window::r_plot::word_corresp->d_l'), # '�ɥåȤȥ�٥�',
		kh_msg->get('gui_window::r_plot::word_corresp->d'), # '�ɥåȤΤ�',
	];
}

sub save{
	my $self = shift;

	# ��¸��λ���
	my @types = (
		[ "PDF",[qw/.pdf/] ],
		[ "Encapsulated PostScript",[qw/.eps/] ],
		[ "SVG",[qw/.svg/] ],
		[ "PNG",[qw/.png/] ],
		[ "CSV",[qw/.csv/] ],
		[ "R Source",[qw/.r/] ],
	);
	@types = ([ "Enhanced Metafile",[qw/.emf/] ], @types)
		if $::config_obj->os eq 'win32';

	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.pdf',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt(kh_msg->get('gui_window::r_plot->saving')), # �ץ��åȤ���¸
		-initialdir       => $self->gui_jchar($::config_obj->cwd)
	);

	$path = $self->gui_jg_filename_win98($path);
	$path = $self->gui_jg($path);
	$path = $::config_obj->os_path($path);

	$self->{plots}[$self->{ax}]->save($path) if $path;

	return 1;
}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_corresp->view'); # ' ɽ����';
}

sub win_title{
	return kh_msg->get('win_title'); # �����ǥ��󥰡�¿��������ˡ
}

sub win_name{
	return 'w_cod_mds_plot';
}


sub base_name{
	return 'cod_mds';
}

1;