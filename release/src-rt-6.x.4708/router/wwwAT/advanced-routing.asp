<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title><% translate("Routing"); %></title>
<content>
	<script type="text/javascript">
		// <% nvram("wk_mode,dr_setting,lan_stp,routes_static,dhcp_routes,lan_ifname,lan1_ifname,lan2_ifname,lan3_ifname,wan_ifname,wan_iface,wan2_ifname,wan2_iface,wan3_ifname,wan3_iface,wan4_ifname,wan4_iface,emf_enable,dr_lan_rx,dr_lan1_rx,dr_lan2_rx,dr_lan3_rx,dr_wan_rx,dr_wan2_rx,dr_wan3_rx,dr_wan4_rx,wan_proto,wan2_proto,wan3_proto,wan4_proto,mwan_num"); %>
		// <% activeroutes(); %>

		var ara = new TomatoGrid();

		ara.setup = function() {
			var i, a;
			this.init('ara-grid', 'sort');
			this.headerSet(['<% translate("Destination"); %>', '<% translate("Gateway / Next Hop"); %>', '<% translate("Subnet Mask"); %>', '<% translate("Metric"); %>','<% translate("Interface"); %>']);
			for (i = 0; i < activeroutes.length; ++i) {
				a = activeroutes[i];
				if (a[0] == nvram.lan_ifname) a[0] += ' (<% translate("LAN"); %>)';
				else if (a[0] == nvram.lan1_ifname) a[0] += ' (<% translate("LAN1"); %>)';
				else if (a[0] == nvram.lan2_ifname) a[0] += ' (<% translate("LAN2"); %>)';
				else if (a[0] == nvram.lan3_ifname) a[0] += ' (<% translate("LAN3"); %>)';
				else if (a[0] == nvram.wan_iface) a[0] += ' (<% translate("WAN"); %>)';
				else if (a[0] == nvram.wan_ifname) a[0] += ' (<% translate("MAN"); %>)';
				else if (a[0] == nvram.wan2_iface) a[0] += ' (<% translate("WAN2"); %>)';
				else if (a[0] == nvram.wan2_ifname) a[0] += ' (<% translate("MAN2"); %>)';
				/* MULTIWAN-BEGIN */
				else if (a[0] == nvram.wan3_iface) a[0] += ' (<% translate("WAN3"); %>)';
				else if (a[0] == nvram.wan3_ifname) a[0] += ' (<% translate("MAN3"); %>)';
				else if (a[0] == nvram.wan4_iface) a[0] += ' (<% translate("WAN4"); %>)';
				else if (a[0] == nvram.wan4_ifname) a[0] += ' (<% translate("MAN4"); %>)';
				/* MULTIWAN-END */
				this.insertData(-1, [a[1],a[2],a[3],a[4],a[0]]);
			}
		}
		var ars = new TomatoGrid();
		ars.verifyFields = function(row, quiet) {
			var f = fields.getAll(row);
			f[5].value = f[5].value.replace('>', '_');
			return v_ip(f[0], quiet) && v_ip(f[1], quiet) && v_netmask(f[2], quiet) && v_range(f[3], quiet, 0, 10) && v_nodelim(f[5], quiet, '<% translate("Description"); %>');
		}
		ars.setup = function() {
			this.init('ars-grid', '', 20, [
				{ type: 'text', maxlen: 15 }, { type: 'text', maxlen: 15 }, { type: 'text', maxlen: 15 },
				{ type: 'text', maxlen: 3 }, { type: 'select', options: [['LAN','<% translate("LAN"); %>'],['LAN1','<% translate("LAN1"); %>'],['LAN2','<% translate("LAN2"); %>'],['LAN3','<% translate("LAN3"); %>'],['WAN','<% translate("WAN"); %>'],['MAN','<% translate("MAN"); %>']] }, { type: 'text', maxlen: 32 }]);
			this.headerSet(['<% translate("Destination"); %>', '<% translate("Gateway"); %>', '<% translate("Subnet Mask"); %>', '<% translate("Metric"); %>', '<% translate("Interface"); %>','<% translate("Description"); %>']);
			var routes = nvram.routes_static.split('>');
			for (var i = 0; i < routes.length; ++i) {
				var r;
				if (r = routes[i].match(/^(.+)<(.+)<(.+)<(\d+)<(LAN|LAN1|LAN2|LAN3|WAN|MAN)<(.*)$/)) {
					this.insertData(-1, [r[1], r[2], r[3], r[4], r[5],r[6]]);
				}
			}
			this.showNewEditor();
			this.resetNewEditor();
		}

		ars.resetNewEditor = function() {
			var i, e;

			e = fields.getAll(this.newEditor);

			/* VLAN-BEGIN */
			if(nvram.lan_ifname.length < 1)
				e[4].options[0].disabled=true;
			else
				e[4].options[0].disabled=false;
			if(nvram.lan1_ifname.length < 1)
				e[4].options[1].disabled=true;
			else
				e[4].options[1].disabled=false;
			if(nvram.lan2_ifname.length < 1)
				e[4].options[2].disabled=true;
			else
				e[4].options[2].disabled=false;
			if(nvram.lan3_ifname.length < 1)
				e[4].options[3].disabled=true;
			else
				e[4].options[3].disabled=false;
			/* VLAN-END */

			ferror.clearAll(e);
			for (i = 0; i < e.length; ++i) {
				var f = e[i];
				if (f.selectedIndex) f.selectedIndex = 0;
				else f.value = '';
			}
			try { if (e.length) e[0].focus(); } catch (er) { }
		}

		function verifyFields(focused, quiet)
		{
			/* VLAN-BEGIN */
			E('_f_dr_lan').disabled = (nvram.lan_ifname.length < 1);
			if (E('_f_dr_lan').disabled)
				E('_f_dr_lan').checked = false;
			E('_f_dr_lan1').disabled = (nvram.lan1_ifname.length < 1);
			if (E('_f_dr_lan1').disabled)
				E('_f_dr_lan1').checked = false;
			E('_f_dr_lan2').disabled = (nvram.lan2_ifname.length < 1);
			if (E('_f_dr_lan2').disabled)
				E('_f_dr_lan2').checked = false;
			E('_f_dr_lan3').disabled = (nvram.lan3_ifname.length < 1);
			if (E('_f_dr_lan3').disabled)
				E('_f_dr_lan3').checked = false;
			for (uidx = 1; uidx <= nvram.mwan_num; ++uidx) {
				u = (uidx>1) ? uidx : '';
				E('_f_dr_wan'+u).disabled = (nvram['wan'+u+'_proto'] == 'disabled');
				if (E('_f_dr_wan'+u).disabled)
					E('_f_dr_wan'+u).checked = false;
			}
			for (uidx = 4; uidx > nvram.mwan_num; --uidx){
				u = (uidx>1) ? uidx : '';
				E('_f_dr_wan'+u).disabled = 1;
			}
			/* VLAN-END */
			return 1;
		}

		function save()
		{
			if (ars.isEditing()) return;

			var fom = E('_fom');
			var data = ars.getAllData();
			var r = [];
			for (var i = 0; i < data.length; ++i) r.push(data[i].join('<'));
			fom.routes_static.value = r.join('>');

			/* ZEBRA-BEGIN */

			/* NOVLAN-BEGIN */
			var wan = '0';
			var lan = '0';

			switch (E('_dr_setting').value) {
				case '1':
					lan = '1 2';
					break;
				case '2':
					wan = '1 2';
					break;
				case '3':
					lan = '1 2';
					wan = '1 2';
					break;
			}
			fom.dr_lan_tx.value = fom.dr_lan_rx.value = lan;
			fom.dr_wan_tx.value = fom.dr_wan_rx.value = wan;
			/* NOVLAN-END */

			/* VLAN-BEGIN */
			fom.dr_lan_tx.value = fom.dr_lan_rx.value = (E('_f_dr_lan').checked) ? '1 2' : '0';
			fom.dr_lan1_tx.value = fom.dr_lan1_rx.value = (E('_f_dr_lan1').checked) ? '1 2' : '0';
			fom.dr_lan2_tx.value = fom.dr_lan2_rx.value = (E('_f_dr_lan2').checked) ? '1 2' : '0';
			fom.dr_lan3_tx.value = fom.dr_lan3_rx.value = (E('_f_dr_lan3').checked) ? '1 2' : '0';
			fom.dr_wan_tx.value = fom.dr_wan_rx.value = (E('_f_dr_wan').checked) ? '1 2' : '0';
			fom.dr_wan2_tx.value = fom.dr_wan2_rx.value = (E('_f_dr_wan2').checked) ? '1 2' : '0';
			/* MULTIWAN-BEGIN */
			fom.dr_wan3_tx.value = fom.dr_wan3_rx.value = (E('_f_dr_wan3').checked) ? '1 2' : '0';
			fom.dr_wan4_tx.value = fom.dr_wan4_rx.value = (E('_f_dr_wan4').checked) ? '1 2' : '0';
			/* MULTIWAN-END */
			/* VLAN-END */

			/* ZEBRA-END */

			/* NOVLAN-BEGIN */
			fom.lan_stp.value = E('_f_stp').checked ? 1 : 0;
			/* NOVLAN-END */

			fom.dhcp_routes.value = E('_f_dhcp_routes').checked ? '1' : '0';
			fom._service.value = (fom.dhcp_routes.value != nvram.dhcp_routes) ? 'wan-restart' : 'routing-restart';

			/* EMF-BEGIN */
			fom.emf_enable.value = E('_f_emf').checked ? 1 : 0;
			if (fom.emf_enable.value != nvram.emf_enable) fom._service.value = '*';
			/* EMF-END */

			form.submit(fom, 1);
		}

		function submit_complete()
		{
			reloadPage();
		}

		function earlyInit()
		{
			ara.setup();
			ars.setup();
			init();
		}

		function init()
		{
			ara.recolor();
			ars.recolor();
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#advanced-routing.asp">
		<input type="hidden" name="_service" value="routing-restart">

		<input type="hidden" name="routes_static">
		<input type="hidden" name="dhcp_routes">
		<input type="hidden" name="emf_enable">
		<!-- NOVLAN-BEGIN -->
		<input type="hidden" name="lan_stp">
		<!-- NOVLAN-END -->
		<input type="hidden" name="dr_lan_tx">
		<input type="hidden" name="dr_lan_rx">
		<!-- VLAN-BEGIN -->
		<input type="hidden" name="dr_lan1_tx">
		<input type="hidden" name="dr_lan1_rx">
		<input type="hidden" name="dr_lan2_tx">
		<input type="hidden" name="dr_lan2_rx">
		<input type="hidden" name="dr_lan3_tx">
		<input type="hidden" name="dr_lan3_rx">
		<!-- VLAN-END -->
		<input type="hidden" name="dr_wan_tx">
		<input type="hidden" name="dr_wan_rx">
		<input type="hidden" name="dr_wan2_tx">
		<input type="hidden" name="dr_wan2_rx">
		<!-- MULTIWAN-BEGIN -->
		<input type="hidden" name="dr_wan3_tx">
		<input type="hidden" name="dr_wan3_rx">
		<input type="hidden" name="dr_wan4_tx">
		<input type="hidden" name="dr_wan4_rx">
		<!-- MULTIWAN-END -->

		<div class="box" data-box="routing-table">
			<div class="heading"><% translate("Current Routing Table"); %></div>
			<div class="section content">
				<table class="line-table" id="ara-grid"></table><br />
			</div>
		</div>

		<div class="box" data-box="routing-static">
			<div class="heading"><% translate("Static Routing Table"); %></div>
			<div class="section content">
				<table class="line-table" id="ars-grid"></table>
			</div>
		</div>

		<div class="box" data-box="routing-misc">
			<div class="heading"><% translate("Miscellaneous"); %></div>
			<div class="content misc"></div>
			<script type="text/javascript">
				$('.content.misc').forms([
					{ title: '<% translate("Mode"); %>', name: 'wk_mode', type: 'select', options: [['gateway','<% translate("Gateway"); %>'],['router','<% translate("Router"); %>']], value: nvram.wk_mode },
					/* ZEBRA-BEGIN */
					/* VLAN-BEGIN */
					{ title: 'RIPv1 &amp; v2' },
					{ title: '<% translate("LAN"); %>', indent: 2, name: 'f_dr_lan', type: 'checkbox', value: ((nvram.dr_lan_rx != '0') && (nvram.dr_lan_rx != '')) },
					{ title: '<% translate("LAN1"); %>', indent: 2, name: 'f_dr_lan1', type: 'checkbox', value: ((nvram.dr_lan1_rx != '0') && (nvram.dr_lan1_rx != '')) },
					{ title: '<% translate("LAN2"); %>', indent: 2, name: 'f_dr_lan2', type: 'checkbox', value: ((nvram.dr_lan2_rx != '0') && (nvram.dr_lan2_rx != '')) },
					{ title: '<% translate("LAN3"); %>', indent: 2, name: 'f_dr_lan3', type: 'checkbox', value: ((nvram.dr_lan3_rx != '0') && (nvram.dr_lan3_rx != '')) },
					{ title: '<% translate("WAN"); %>', indent: 2, name: 'f_dr_wan', type: 'checkbox', value: ((nvram.dr_wan_rx != '0') && (nvram.dr_wan_rx != '')) },
					{ title: '<% translate("WAN2"); %>', indent: 2, name: 'f_dr_wan2', type: 'checkbox', value: ((nvram.dr_wan2_rx != '0') && (nvram.dr_wan2_rx != '')) },
					/* MULTIWAN-BEGIN */
					{ title: '<% translate("WAN3"); %>', indent: 2, name: 'f_dr_wan3', type: 'checkbox', value: ((nvram.dr_wan3_rx != '0') && (nvram.dr_wan3_rx != '')) },
					{ title: '<% translate("WAN4"); %>', indent: 2, name: 'f_dr_wan4', type: 'checkbox', value: ((nvram.dr_wan4_rx != '0') && (nvram.dr_wan4_rx != '')) },
					/* MULTIWAN-END */
					/* VLAN-END */
					/* NOVLAN-BEGIN */
					{ title: 'RIPv1 &amp; v2', name: 'dr_setting', type: 'select',	options: [[0,'<% translate("Disabled"); %>'],[1,'<% translate("LAN"); %>'],[2,'<% translate("WAN"); %>'],[3,'<% translate("Both"); %>']], value:	nvram.dr_setting },
					/* NOVLAN-END */
					/* ZEBRA-END */
					/* EMF-BEGIN */
					{ title: '<% translate("Efficient Multicast Forwarding"); %>', name: 'f_emf', type: 'checkbox', value: nvram.emf_enable != '0' },
					/* EMF-END */
					{ title: '<% translate("DHCP Routes"); %>', name: 'f_dhcp_routes', type: 'checkbox', value: nvram.dhcp_routes != '0' },
					/* NOVLAN-BEGIN */
					{ title: '<% translate("Spanning-Tree Protocol"); %>', name: 'f_stp', type: 'checkbox', value: nvram.lan_stp != '0' }
					/* NOVLAN-END */
				]);
			</script>
		</div>

		<button type="button" value="<% translate("Save"); %>" id="save-button" onclick="save()" class="btn btn-primary"><% translate("Save"); %> <i class="icon-check"></i></button>
		<button type="button" value="<% translate("Cancel"); %>" id="cancel-button" onclick="javascript:reloadPage();" class="btn"><% translate("Cancel"); %> <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">earlyInit(); verifyFields(null, 1);</script>
</content>
