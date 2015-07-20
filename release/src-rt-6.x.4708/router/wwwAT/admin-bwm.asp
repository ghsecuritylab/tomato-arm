<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title><% translate("Bandwidth Monitoring"); %></title>
<content>
	<script type="text/javascript">

		// <% nvram("at_update,tomatoanon_answer,rstats_enable,rstats_path,rstats_stime,rstats_offset,rstats_exclude,rstats_sshut,et0macaddr,cifs1,cifs2,jffs2_on,rstats_bak"); %>

		function backupNameChanged()
		{
			if (location.href.match(/^(http.+?\/.+\/)/)) {
				// E('backup-link').href = RegExp.$1 + 'bwm/' + fixFile(E('backup-name').value) + '.gz?_http_id=' + nvram.http_id;
			}
		}

		function backupButton()
		{
			var name;

			name = fixFile(E('backup-name').value);
			if (name.length <= 1) {
				alert('<% translate("Invalid filename"); %>');
				return false;
			}
			location.href = '/bwm/' + name + '.gz?_http_id=' + nvram.http_id;
		}

		function restoreButton()
		{
			var fom;
			var name;
			var i;

			name = fixFile(E('restore-name').value);
			name = name.toLowerCase();
			if ((name.length <= 3) || (name.substring(name.length - 3, name.length).toLowerCase() != '.gz')) {
				alert('<% translate("Incorrect filename. Expecting a"); %> ".gz" <% translate("file"); %>.');
				return false;
			}
			if (!confirm('<% translate("Restore data from"); %> ' + name + '?')) return false;

			E('restore-button').disabled = 1;
			fields.disableAll(E('config-section'), 1);
			fields.disableAll(E('backup-section'), 1);
			fields.disableAll(E('footer'), 1);

			E('restore-form').submit();
		}

		function getPath()
		{
			var s = E('_f_loc').value;
			return (s == '*user') ? E('_f_user').value : s;
		}

		function verifyFields(focused, quiet)
		{
			var b, v;
			var path;
			var eLoc, eUser, eTime, eOfs;
			var bak;

			eLoc = E('_f_loc');
			eUser = E('_f_user');
			eTime = E('_rstats_stime');
			eOfs = E('_rstats_offset');

			b = !E('_f_rstats_enable').checked;
			eLoc.disabled = b;
			eUser.disabled = b;
			eTime.disabled = b;
			eOfs.disabled = b;
			E('_f_new').disabled = b;
			E('_f_sshut').disabled = b;
			E('backup-button').disabled = b;
			E('backup-name').disabled = b;
			E('restore-button').disabled = b;
			E('restore-name').disabled = b;
			ferror.clear(eLoc);
			ferror.clear(eUser);
			ferror.clear(eOfs);
			if (b) return 1;

			path = getPath();
			E('newmsg').style.visibility = ((nvram.rstats_path != path) && (path != '*nvram') && (path != '')) ? 'visible' : 'hidden';

			bak = 0;
			v = eLoc.value;
			b = (v == '*user');
			elem.display(eUser, b);
			if (b) {
				if (!v_path(eUser, quiet, 1)) return 0;
			}
			/* JFFS2-BEGIN */
			else if (v == '/jffs/') {
				if (nvram.jffs2_on != '1') {
					ferror.set(eLoc, 'JFFS2 <% translate("is not enabled"); %>.', quiet);
					return 0;
				}
			}
			/* JFFS2-END */
			/* CIFS-BEGIN */
			else if (v.match(/^\/cifs(1|2)\/$/)) {
				if (nvram['cifs' + RegExp.$1].substr(0, 1) != '1') {
					ferror.set(eLoc, 'CIFS #' + RegExp.$1 + ' <% translate("is not enabled"); %>.', quiet);
					return 0;
				}
			}
			/* CIFS-END */
			else {
				bak = 1;
			}

			E('_f_bak').disabled = bak;

			return v_range(eOfs, quiet, 1, 31);
		}

		function save()
		{
			var fom, path, en, e, aj;

			if (!verifyFields(null, false)) return;

			aj = 1;
			en = E('_f_rstats_enable').checked;
			fom = E('_fom');
			fom._service.value = 'rstats-restart';
			if (en) {
				path = getPath();
				if (((E('_rstats_stime').value * 1) <= 48) &&
					((path == '*nvram') || (path == '/jffs/'))) {
					if (!confirm('<% translate("Frequent saving to NVRAM or JFFS2 is not recommended. Continue anyway?"); %>')) return;
				}
				if ((nvram.rstats_path != path) && (fom.rstats_path.value != path) && (path != '') && (path != '*nvram') &&
					(path.substr(path.length - 1, 1) != '/')) {
					if (!confirm('<% translate("Note"); %>: ' + path + ' <% translate("will be treated as a file. If this is a directory, please use a trailing /. Continue anyway?"); %>')) return;
				}
				fom.rstats_path.value = path;

				if (E('_f_new').checked) {
					fom._service.value = 'rstatsnew-restart';
					aj = 0;
				}
			}

			fom.rstats_path.disabled = !en;
			fom.rstats_enable.value = en ? 1 : 0;
			fom.rstats_sshut.value = E('_f_sshut').checked ? 1 : 0;
			fom.rstats_bak.value = E('_f_bak').checked ? 1 : 0;

			e = E('_rstats_exclude');
			e.value = e.value.replace(/\s+/g, ',').replace(/,+/g, ',');

			fields.disableAll(E('backup-section'), 1);
			fields.disableAll(E('restore-section'), 1);
			form.submit(fom, aj);
			if (en) {
				fields.disableAll(E('backup-section'), 0);
				fields.disableAll(E('restore-section'), 0);
			}
		}

		function init()
		{
			backupNameChanged();
		}
	</script>

	<div class="box" id="config-section">
		<div class="heading"><% translate("Bandwidth Monitoring"); %> - <% translate("Settings"); %></div>
		<div class="content">
			<form id="_fom" method="post" action="tomato.cgi" style="margin: 0;">
				<input type="hidden" name="_nextpage" value="/#admin-bwm.asp">
				<input type="hidden" name="_service" value="rstats-restart">
				<input type="hidden" name="rstats_enable">
				<input type="hidden" name="rstats_path">
				<input type="hidden" name="rstats_sshut">
				<input type="hidden" name="rstats_bak">

				<script type="text/javascript">
					switch (nvram.rstats_path) {
						case '':
						case '*nvram':
						case '/jffs/':
						case '/cifs1/':
						case '/cifs2/':
							loc = nvram.rstats_path;
							break;
						default:
							loc = '*user';
							break;
					}
					$('#config-section form:first').forms([
						{ title: '<% translate("Enable"); %>', name: 'f_rstats_enable', type: 'checkbox', value: nvram.rstats_enable == '1' },
						{ title: '<% translate("Save History Location"); %>', multi: [
							{ name: 'f_loc', type: 'select', options: [['','<% translate("RAM (Temporary)"); %>'],['*nvram','NVRAM'],
								/* JFFS2-BEGIN */
								['/jffs/','JFFS2'],
								/* JFFS2-END */
								/* CIFS-BEGIN */
								['/cifs1/','CIFS 1'],['/cifs2/','CIFS 2'],
								/* CIFS-END */
								['*user','<% translate("Custom Path"); %>']], value: loc },
							{ name: 'f_user', type: 'text', maxlen: 48, size: 50, value: nvram.rstats_path }
						] },
						{ title: '<% translate("Save Frequency"); %>', indent: 2, name: 'rstats_stime', type: 'select', value: nvram.rstats_stime, options: [
							[1,'<% translate("Every Hour"); %>'],[2,'<% translate("Every 2 Hours"); %>'],[3,'<% translate("Every 3 Hours"); %>'],[4,'<% translate("Every 4 Hours"); %>'],[5,'<% translate("Every 5 Hours"); %>'],[6,'<% translate("Every 6 Hours"); %>'],
							[9,'<% translate("Every 9 Hours"); %>'],[12,'<% translate("Every 12 Hours"); %>'],[24,'<% translate("Every 24 Hours"); %>'],[48,'<% translate("Every 2 Days"); %>'],[72,'<% translate("Every 3 Days"); %>'],[96,'<% translate("Every 4 Days"); %>'],
							[120,'<% translate("Every 5 Days"); %>'],[144,'<% translate("Every 6 Days"); %>'],[168,'<% translate("Every Week"); %>']] },
						{ title: '<% translate("Save On Shutdown"); %>', indent: 2, name: 'f_sshut', type: 'checkbox', value: nvram.rstats_sshut == '1' },
						{ title: '<% translate("Create New File"); %><br><small>(<% translate("Reset Data"); %>)</small>', indent: 2, name: 'f_new', type: 'checkbox', value: 0,
							suffix: ' &nbsp;<small id="newmsg" style="visibility:hidden"><% translate("Enable if this is a new file"); %></small>' },
						{ title: '<% translate("Create Backups"); %>', indent: 2, name: 'f_bak', type: 'checkbox', value: nvram.rstats_bak == '1' },
						{ title: '<% translate("First Day Of The Month"); %>', name: 'rstats_offset', type: 'text', value: nvram.rstats_offset, maxlen: 2, size: 4 },
						{ title: '<% translate("Excluded Interfaces"); %>', name: 'rstats_exclude', type: 'text', value: nvram.rstats_exclude, maxlen: 64, size: 50, suffix: '<small>(<% translate("comma separated list"); %>)</small>' }
						], { align: 'left' });
				</script>
			</form><hr><br />

			<div class="col-sm-12">
				<h4><% translate("Backup"); %></h4>
				<div class="section" id="backup-section">
					<form>
						<div class="input-append">
							<script type="text/javascript">
								$('#backup-section .input-append').prepend('<input size="40" type="text" maxlength="64" id="backup-name" name="backup_name" onchange="backupNameChanged()" value="tomato_rstats_' + nvram.et0macaddr.replace(/:/g, '').toLowerCase() + '">');
							</script>
							<button name="f_backup_button" id="backup-button" onclick="backupButton(); return false;" value="<% translate("Backup"); %>" class="btn"><% translate("Backup"); %> <i class="icon-download"></i></button>
						</div>
					</form>
				</div>
			</div>

			<div class="col-sm-12">
				<h4><% translate("Restore"); %></h4>
				<div class="section" id="restore-section">
					<form id="restore-form" method="post" action="bwm/restore.cgi?_http_id=<% nv(http_id); %>" encType="multipart/form-data">
						<input class="uploadfile" type="file" size="40" id="restore-name" name="restore_name" accept="application/x-gzip">
						<button name="f_restore_button" id="restore-button" value="<% translate("Restore"); %>" onclick="restoreButton(); return false;" class="btn"><% translate("Restore"); %> <i class="icon-upload"></i></button>
						<br>
					</form>
				</div>
			</div>
		</div>
	</div>

	<button type="button" value="<% translate("Save"); %>" id="save-button" onclick="save()" class="btn btn-primary"><% translate("Save"); %> <i class="icon-check"></i></button>
	<button type="button" value="<% translate("Cancel"); %>" id="cancel-button" onclick="javascript:reloadPage();" class="btn"><% translate("Cancel"); %> <i class="icon-cancel"></i></button>
	<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span><br /><br />

	<script type="text/javascript">init(); verifyFields(null, 1);</script>
</content>
