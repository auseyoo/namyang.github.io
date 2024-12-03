<!-- 
	@File Name: 
	@File ���� : 
	@UI ID : 
	@�ۼ��� : 2022. 1. 19.
	@�ۼ��� : YESOL
 -->
<%@ page language="java" contentType="text/html; charset=EUC-KR"
	pageEncoding="EUC-KR"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<script type="text/javascript">
//AUIGrid ���� �� ��ȯ ID
var mGrid;
var markers = [];
var bounds = new kakao.maps.LatLngBounds();
var map;

$(document).ready(function(){
	var container = document.getElementById("map"); //������ ���� ������ DOM ���۷���
	var options = { //������ ������ �� �ʿ��� �⺻ �ɼ�
		center: new kakao.maps.LatLng(33.450701, 126.570667), //������ �߽���ǥ.
		level: 3 //������ ����(Ȯ��, ��� ����)
	};

	map = new kakao.maps.Map(container, options); //���� ���� �� ��ü ����

	createAUIGrid();
});

function convert() {
	var input = $('#monkeyinput').val();
	var count = 0;
	var output1 = '';
	var output2 = '';

	var lines = input.split(/\n/);
	for(var i = 0, maxi = lines.length; i < maxi; i++) {
		var before = lines[i];
		before = $.trim(before.toLowerCase());

		// skip empty lines
		if(before == '') {
			continue;
		}

		// conversion
		var after = before.replace(/_(\w)/g, function(word) {
			return word.toUpperCase();
		});
		after = after.replace(/_/g, "");
		// console.log('\t' + before + ' ->> ' + after);

		// make result for each
		if($('#code_basic:checked').val()) {
			output1 += (after + '\n');
		}
		// Value Object
		else if($('#code_vo:checked').val()) {
			var modifier = $('#modifier option:selected').val();
			var datatype = $('#datatype option:selected').val();

			// hibernate annatation
			if(document.conf.hibernate.checked) {
				output1 += ('@Column(name = "' + before + '")\n' + modifier + ' ' + datatype + ' ' + after + ';\n\n');
			}
			else {
				output1 += (modifier + ' ' + datatype + ' ' + after + ';\n');
			}
		}
		// ResultMap
		else if($('#code_resultmap:checked').val()) {
			output1 += ('\t<result property="' + after + '" column="' + before + '" />\n');
		}
		// Select
		else if($('#code_select:checked').val()) {
			if(count == 0) {
				output1 += (before);
			}
			else {
				output1 += (',\n\t' + before);
			}

			if(count == 0) {
				output2 += (before + ' = #' + after + '#\n');
			}
			else {
				output2 += ('AND\t' + before + ' = #' + after + '#\n');
			}
		}
		// Insert
		else if($('#code_insert:checked').val()) {
			if(count == 0) {
				output1 += (before);
			}
			else {
				output1 += (', ' + before);
			}

			if(count == 0) {
				output2 += ('#' + after + '#');
			}
			else {
				output2 += (', #' + after + '#');
			}
		}
		// Update
		else if($('#code_update:checked').val()) {
			if(count == 0) {
				output1 += (before + ' = #' + after + '#');
			}
			else {
				output1 += (',\n\t' + before + ' = #' + after + '#');
			}

			if(count == 0) {
				output2 += (before + ' = #' + after + '#\n');
			}
			else {
				output2 += ('AND\t' + before + ' = #' + after + '#\n');
			}
		}
		// Delete
		else if($('#code_delete:checked').val()) {
			if(count == 0) {
				output1 += (before + ' = #' + after + '#\n');
			}
			else {
				output1 += ('AND\t' + before + ' = #' + after + '#\n');
			}
		}
		else {
			output1 += (after + '\n');
		}
		count++;
	}

	var output = '';
	if($('#code_basic:checked').val()) {
		output = output1;
	}
	else if($('#code_vo:checked').val()) {
		output = output1;
	}
	else if($('#code_resultmap:checked').val()) {
		output = '<resultMap id="' + document.conf._id.value + '" class="' + document.conf._class.value + '">\n';
		output += output1;
		output += '</resultMap>';
	}
	else if($('#code_select:checked').val()) {
		output = 'SELECT\t';
		output += output1 + '\n';
		output += 'FROM\t' + getTableName() + ' \n';
		output += 'WHERE\t';
		output += output2;
	}
	else if($('#code_insert:checked').val()) {
		output = 'INSERT INTO ' + getTableName() + '(' + output1 + ') \n';
		output += 'VALUES(' + output2 + ')';
	}
	else if($('#code_update:checked').val()) {
		output = 'UPDATE\t' + getTableName() + ' \n';
		output += 'SET\t' + output1 + '\n';
		output += 'WHERE\t';
		output += output2;
	}
	else if($('#code_delete:checked').val()) {
		output = 'DELETE FROM ' + getTableName() + ' \n';
		output += 'WHERE\t';
		output += output1;
	}
	$('#monkeyoutput').text(output);
}

function getTableName() {
	var tableName = $('input[name=table]').val();
	if(tableName != '') {
		return tableName;
	}
	return '[table_name]';
}

function fillOptionBox() {
	var html = [];
	html.push('<p>');
	html.push('Table: <input id="table" type="text" name="table" onkeyup="convert();" />');
	html.push('</p>');
	$('#options').html(html.join(''));
	$('#table').focus();
	convert();
}

function createAUIGrid() {
	var auiGridProps = {
			rowIdField : "cstSeq",
			// ���� ���� ����
			editable : true,
			// ���� Ȱ��ȭ
			enableFilter : true,
			// ���� ǥ��
			showStateColumn : true,
			// row Height
			headerHeight : 60
	};

	//AUIGrid Į�� ����		formatString : "#,##0",	style : "left",
	var columnLayout = [ 
		{	dataField : "cstSeq",	headerText : "�Ϸù�ȣ",		width:100,	visible:false	},
		{	dataField : "agenSeq",	headerText : "�븮��",		width:100	},
		{	dataField : "areaSeq",	headerText : "����",			width:100,	style : "left"	},
		{	dataField : "cstAgenCd",headerText : "�븮���ڵ�",		width:100	},
		{	dataField : "dlvZipCd", headerText : "�����ȣ",		width:100	},
		{	dataField : "dlvAddr1",	headerText : "�ּ�1",			width:250,	style : "left"	},
		{	dataField : "dlvAddr2",	headerText : "�ּ�2",			width:250	},
	];
	
	// ������ #grid_wrap �� �׸��� ����
	mGrid = AUIGrid.create("#grid_wrap", columnLayout, auiGridProps);
}

function searchList(){
	$.ajax({
		url : "/comm/selectAddr.do", 
		type : 'POST', 
		data : $("#frm").serialize(),
		success : function(data) {
			AUIGrid.setGridData(mGrid, data);
			arrList = data;
		}, // success 
		error : function(xhr, status) {
			alert(xhr + " : " + status);
		}
	}); 	
}

function searchAddr(){
	
	var rowPos = AUIGrid.getSelectedRows(mGrid);
	var addr =  rowPos[0].dlvAddr1+" "+rowPos[0].dlvAddr2;
	console.log(addr);
	var geocoder = new kakao.maps.services.Geocoder();
	// Ű����� ��Ҹ� �˻��մϴ�
	geocoder.addressSearch(addr, placeCallback); 
}

function placeCallback (data, status, pagination) {
	console.log(data);
	if (status === kakao.maps.services.Status.OK) {
		// �˻��� ��� ��ġ�� �������� ���� ������ �缳���ϱ�����
		// LatLngBounds ��ü�� ��ǥ�� �߰��մϴ�

		for (var i=0; i<data.length; i++) {
			displayMarker(data[i]);	
			bounds.extend(new kakao.maps.LatLng(data[i].y, data[i].x));
		}	   
		// �˻��� ��� ��ġ�� �������� ���� ������ �缳���մϴ�
		map.setBounds(bounds);
	} 
}

function searchAddr(){
	var rowPos = AUIGrid.getSelectedRows(mGrid);
	var addr =  rowPos[0].dlvAddr1+" "+rowPos[0].dlvAddr2;
	var geocoder = new kakao.maps.services.Geocoder();
	// Ű����� ��Ҹ� �˻��մϴ�
	geocoder.addressSearch(addr, placeCallback); 
}

//������ ��Ŀ�� ǥ���ϴ� �Լ��Դϴ�
function displayMarker(place) {
	
	// ��Ŀ�� �����ϰ� ������ ǥ���մϴ�
	var marker = new kakao.maps.Marker({
		map: map,
		position: new kakao.maps.LatLng(place.y, place.x) 
	});

	marker.setMap(map);
	markers.push(marker);

	map.setBounds(bounds);
}

function openPop(){
	$.ajaxDialog({
		id: "readPop",
		ajax: {
			url: "/comm/pop/samplePop.pop",
		},
		dialog: {
			width:1600,
			height:800
		},
		success: function(data) {
			alert("����� ���ϵ� ���� >> "+ data.prdNm);
			
		}
	});
}

</script>
<div class="content">
	<tiles:insertAttribute name="body.breadcrumb"/>
	
	<!-- ��ȸ -->
	<form id="frm">
		<div class="inquiryBox">
			<dl>
				<dt>�ּ�</dt>
				<dd>
					<input type="text" id="addr" name="addr" class="inp" value="" title="">
				</dd>
				<dd>
					<button type="button" name="" class="inquBtn" id="inp_name01" onclick="searchList()">��ȸ</button>
					<button type="button" name="" class="inquBtn" id="inp_name01" onclick="searchAddr()">��ǥ</button>
				</dd>
			</dl>
	
			<div class="btnGroup right">
				<!-- <button type="button" id="popBtn"	class="comBtn">�˾�</button> -->
			</div>
		</div>
	</form>
	<!-- ��ȸ -->
	
	<div class="titleArea">
		<h3 class="tit01">�˾�</h3>
	</div>
		<div class="inquiryBox">
			<dl>
				<dd>
					<button type="button" name="" class="inquBtn" id="inp_name01" onclick="openPop()">�˾�</button>
				</dd>
			</dl>
	
			<div class="btnGroup right">
				<!-- <button type="button" id="popBtn"	class="comBtn">�˾�</button> -->
			</div>
		</div>
	
	
	<div class="girdBoxGroup">
		<div class="girdBox w55per">
			<div class="titleArea">
				<h3 class="tit01">�׸���</h3>
			</div>
			<!-- grid -->
			<div class="gridBox">
				<div id="grid_wrap"></div>
			</div>
		</div>
		
		<div class="conBox w43per">
			<div class="titleArea">
				<h3 class="tit01">����</h3>
			</div>
			
			<div id="map" style="width:500px;height:400px;"></div>
		</div>
	</div>
	<div class="inquiryBox">
	<form name="conf">
		<fieldset>
			<legend>
				Configurations
			</legend>
			<p>
				<strong>Conversion Style</strong>
				<br />
				<div class="checkGroup">
					<input id="code_basic" name="code" checked="" type="radio" class="type01">
					<label for="code_basic">Basic</label>&nbsp;
					<input id="code_vo" name="code" type="radio" class="type01">
					<label for="code_vo">VO</label>&nbsp;
					<input id="code_resultmap" name="code" type="radio" class="type01">
					<label for="code_resultmap">ResultMap</label>&nbsp;
					<input id="code_select" name="code" type="radio" class="type01">
					<label for="code_select">Select</label>&nbsp;
					<input id="code_insert" name="code" type="radio" class="type01">
					<label for="code_insert">Insert</label>&nbsp;
					<input id="code_update" name="code" type="radio" class="type01">
					<label for="code_update">Update</label>&nbsp;
					<input id="code_delete" name="code" type="radio" class="type01">
					<label for="code_delete">Delete</label>&nbsp;
				</div>
				<script type="text/javascript">
					$('#code_basic').click(function() {
						$('#options').html('');
						convert();
					});
	
					$('#code_vo').click(function() {
						var html = [];
						html.push('<p>');
						html.push('<strong>Modifier Datatype</strong><br />');
						html.push('<select id="modifier" onchange="convert();">');
						html.push('	<option>public</option>');
						html.push('	<option>protected</option>');
						html.push('	<option selected>private</option>');
						html.push('</select>');
						html.push('<select id="datatype" onchange="convert();">');
						html.push('	<option>int</option>');
						html.push('	<option>long</option>');
						html.push('	<option>float</option>');
						html.push('	<option>double</option>');
						html.push('	<option>byte[]</option>');
						html.push('	<option>boolean</option>');
						html.push('	<option>char</option>');
						html.push('	<option selected>String</option>');
						html.push('</select>');
						html.push('</p>');
						html.push('<p>');
						html.push('<strong>Hibernate</strong><br />');
						html.push('<input type="checkbox" name="hibernate" value="hibernate" id="hibernate" onclick="convert();" /><label for="hibernate">Use hibernate annotation</label>');
						html.push('</p>');
						$('#options').html(html.join(''));
						convert();
					});
	
					$('#code_resultmap').click(function() {
						var html = [];
						html.push('<p>');
						html.push('id: <input id="_id" type="text" name="id" onkeyup="convert();" />&nbsp;');
						html.push('class: <input id="_class" type="text" name="class" onkeyup="convert();" />');
						html.push('</p>');
						$('#options').html(html.join(''));
						$('#_id').focus();
						convert();
					});
	
					$('#code_select').click(fillOptionBox);
					$('#code_insert').click(fillOptionBox);
					$('#code_update').click(fillOptionBox);
					$('#code_delete').click(fillOptionBox);
				</script>
			</p>
			<div id="options"></div>
		</fieldset>
	</form>
	</div>
	<p>
		<textarea id="monkeyinput" class="camel" style="width:48.5%; height:300px;" onkeyup="convert();"></textarea>
		&nbsp;
		<textarea id="monkeyoutput" class="camel" style="width:48.5%; height:300px;" readonly=""></textarea></p><p><br /></p><p><br /></p><p><span class="imageblock" style="display:inline-block;;height:auto;max-width:100%"></span><br />
	</p>
</div>