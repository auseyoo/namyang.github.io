<!-- 
	@File Name: samplePop.jsp.jsp
	@File 설명 : 공통 팝업 
	@작성일 : 2022. 1. 10.
	@작성자 : YESOL
 -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="code" uri="/WEB-INF/tlds/getCommCode.tld"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="code" uri="/WEB-INF/tlds/getCommCode.tld"%>
<code:makeSelect commGrpCd="TAXT_CD" 	var="taxtCdList"	name="taxtCd"	all="false" />
<style>
/* 커스텀 열 스타일 */
.my-column-style {
	background:#eeeeee;
	color:#005500;
	font-weight:bold;
	padding: 1px solid black;
	
}
</style>

<script type="text/javascript">
var popGrid;	// 메인
$(document).ready(function(){
	/* 그리드 생성*/
	createAUIGrid();

	$("#srchBtn").click(searchList);
	
	/* 검색 멀티 콤보 이벤트 바인드 */
	$(".prdCls").change(function(){
		var target = $(this).data("clsTarget");
		setMultiCombo(target);
	});

	AUIGrid.bind(popGrid, "cellClick", function(event) {
		$.successDialog("<c:out value='${param.id}'/>", event.item);
		$.closeDialog("<c:out value='${param.id}'/>");

	});

	$("#closeBtn").click(function(){
		$.closeDialog("<c:out value='${param.id}'/>");
	});
});
//AUIGrid 를 생성합니다.
function createAUIGrid() {
	popGrid	= AUIGrid.create("#pop_grid_wrap", 	columnLayout,	gridPros);
}

var columnLayout = [
	{
		dataField : "prdSapCd",
		headerText : "제품코드",
		width : "12%" ,
		style : "auiLink"		   	
	},{
		dataField : "prdNm",
		headerText : "제품명",
		style : "auiLeft"		
	},{
		dataField : "lclsNm",
		headerText : "제품<br/>대분류",
		width : "11%"
	},{
		dataField : "mclsNm",
		headerText : "제품<br/>중분류",
		width : "11%"
	},{
		dataField : "sclsNm",
		headerText : "제품<br/>소분류",
		width : "11%"
	},{
		dataField : "dclsNm",
		headerText : "제품<br/>세분류",
		width : "11%"
	},{
		dataField : "ordUseYnTx",
		headerText : "주문여부",
		width : "13%"
	}
];

var gridPros = {
	headerHeight : 58,
	rowHeight : 29,
	// 편집 가능 여부 (기본값 : false)
	editable : false,
	// 엔터키가 다음 행이 아닌 다음 칼럼으로 이동할지 여부 (기본값 : false)
	enterKeyColumnBase : true,
	// 셀 선택모드 (기본값: singleCell)
	selectionMode : "multipleCells",
	//showFooter : true,
	// 컨텍스트 메뉴 사용 여부 (기본값 : false)
	useContextMenu : true,
	// 필터 사용 여부 (기본값 : false)
	enableFilter : true,
	// 그룹핑 패널 사용
	useGroupingPanel : false,
	// 그룹핑 또는 트리로 만들었을 때 펼쳐지게 할지 여부 (기본값 : false)
	displayTreeOpen : true,
	noDataMessage : "출력할 데이터가 없습니다.",
	groupingMessage : "여기에 칼럼을 드래그하면 그룹핑이 됩니다."
};
/* 표준 제품 - 리스트 조회 */
function searchList(){

	
	$.ajax({
		url : "/std/selectPrdMstList.do", 
		type : 'POST', 
		data : $("#popFrm").serialize(),
		success : function(data) {
			AUIGrid.setGridData(popGrid, data);
			$("#dtlCnt").html(data.length);
		}, // success 
		error : function(xhr, status) {
			alert(xhr + " : " + status);
		}
	}); 	
}


/* 표준 제품 등록 팝업 - 리스트 조회 */
function mstSearchList(){
	var popupParam = [];
	if( fnIsEmpty($("#lcls").val())){
		popupParam.data = {
			title : "표준 제품 등록",
	 	 	message : "<spring:message code='alert.noSelect' arguments="${'대분류'}"/>",
	 	 	showBtn2 : 'N'
		}
		layerAlert(popupParam);
		return;
	}
	if( fnIsEmpty($("#mcls").val())){
		popupParam.data = {
			title : "표준 제품 등록",
	 	 	message : "<spring:message code='alert.noSelect' arguments="${'중분류'}"/>",
	 	 	showBtn2 : 'N'
		}
		layerAlert(popupParam);
		return;
	}
	if( fnIsEmpty($("#scls").val())){
		popupParam.data = {
			title : "표준 제품 등록",
	 	 	message : "<spring:message code='alert.noSelect' arguments="${'소분류'}"/>",
	 	 	showBtn2 : 'N'
		}
		layerAlert(popupParam);
		return;
	}
	if( fnIsEmpty($("#dcls").val())){
		popupParam.data = {
			title : "표준 제품 등록",
	 	 	message : "<spring:message code='alert.noSelect' arguments="${'세분류'}"/>",
	 	 	showBtn2 : 'N'
		}
		layerAlert(popupParam);
		return;
	}

	$.ajax({
		url : "/std/selectPrdMstList.do",
		type : 'POST', 
		data : $("#popFrm").serialize(),
		success : function(data) {
			AUIGrid.setGridData(popGrid, data);
			$("#mstCnt").html(data.length);
		}, // success 
		error : function(xhr, status) {
			alert(xhr + " : " + status);
		}
	}); 	
}


/* 검색 멀티콤보 설정 */
function setMultiCombo(type){
	$("#"+type+"cls option").remove();
	switch(parseInt($("#"+type+"cls").data("clsLvl"))){
		case 2 : {
			$("#mcls option").remove();
			$("#mcls").append("<option value=''>중분류</option>");
		}
		case 3 : {
			$("#scls option").remove();
			$("#scls").append("<option value=''>소분류</option>");
		}
		case 4 : {
			$("#dcls option").remove();
			$("#dcls").append("<option value=''>세분류</option>");
		}
	}
	if(fnIsEmpty($("#lcls").val())){ return;}
	$.ajax({
		url : "/comm/selectPrdCls.do", 
		type : 'POST', 
		data : $("#popFrm").serialize(),
		success : function(data) {
			$("#"+type+"cls").append($("#codeTmpl").tmpl({"codeList": data}));
		},
		error : function(xhr, status) {
		}
	}); 	
	
}

function resizeGrid(){
	AUIGrid.resize(popGrid, $("#content").width());
}

</script>

<div class="popArea">
	<div class="popWrap large modal_wrap">
		<header>
			<h3>남양제품 조회</h3>
		</header>  
	
		<!-- popCon -->
		<div class="popCon">
			<div class="popTitArea">
				<h3>남양제품 조회</h3>
				<div class="popBtnArea">
					<button type="button" class="comBtn modalCloseBtn ui-dialog-titlebar-close" id="closeBtn">닫기</button>
				</div>
			</div>
	
			<!-- 조회 -->
			<form id="popFrm" method="post">
				<div class="inquiryBox">
					<dl>
						<dt>자재 그룹</dt>
						<dd>
							<div class="formWrap">
								<select name="prdType" class="sel w120" id="prdType">
									<option value="">전체</option>
									<option value="FER1">제품</option>
									<option value="ERS1">크레이트</option>
									<option value="HAW2">판촉물</option>
								</select>
							</div>
						</dd>
						<dt>분류</dt>
						<dd>
							<div class="formWrap">
								<input type="hidden" id="prdType" name="prdType"/>
								<select name="lcls" class="sel w120 mr10 prdCls" id="lcls" data-cls-target="m" data-cls-lvl="1">
									<option value="">대분류</option>
									<c:forEach items="${lclsList}" var="i" >
										<option value="${i.code}">${i.name}</option>
									</c:forEach>
								</select>
								<select name="mcls" class="sel w120 mr10 prdCls" id="mcls" data-cls-target="s" data-cls-lvl="2">
									<option value="">중분류</option>
								</select>
								<select name="scls" class="sel w120 mr10 prdCls" id="scls" data-cls-target="d" data-cls-lvl="3">
									<option value="">소분류</option>
								</select>
								<select name="dcls" class="sel w120" id="dcls" data-cls-lvl="4">
									<option value="">세분류</option>
								</select>
							</div>
						</dd>
						<dt>제품</dt>
						<dd>
							<div class="formWrap">
								<input type="text" id="srcPrdCd" 	class="inp w120 mr10"	value="" 	name="srcPrdCd"		placeholder="제품코드" maxlength="8">
								<input type="text" id="srcPrdNm" 	class="inp w160 mr7"	value="" 	name="srcPrdNm"		placeholder="제품명">
		
								<button type="button" name="srchBtn" class="comBtn" id="srchBtn">조회</button>
							</div>
						</dd>
					</dl>
				</div>
			</form>
			<!-- 조회 -->
	
			<p class="numState">
				<em>총 <span class="pColor01 fb" id="mstCnt">24</span></em> 건 이 조회되었습니다.
			</p>
			<!-- grid -->
			<div class="girdBox">
				<div id="pop_grid_wrap"></div>
			</div>
			<!-- grid -->
		</div>
		<!-- popCon -->
	</div>
</div>

<script id="codeTmpl" type="text/x-jquery-tmpl">
{{each(i, e) codeList }}
	<option value='\${e.code}'>\${e.name}</option>
{{/each}}
</script>