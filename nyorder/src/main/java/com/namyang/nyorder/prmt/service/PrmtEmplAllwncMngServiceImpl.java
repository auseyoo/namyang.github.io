package com.namyang.nyorder.prmt.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.namyang.nyorder.comm.vo.UserInfo;
import com.namyang.nyorder.prmt.dao.PrmtEmplAllwncMngMapper;
import com.namyang.nyorder.prmt.vo.PrmtEmplAllwncMngVO;

/**
 * 시스템명 : 남양유업 대리점주문 시스템
 * 업무명  : 판촉사원 수당 관리 Service Implement
 * 파일명  : PrmtEmplAllwncMngServiceImpl.java
 * 작성자  : 윤이준
 * 작성일  : 2022. 3. 11.
 *
 * 설 명  :
 * --------------------------------------------------
 *   변경일             변경자           변경내역
 * --------------------------------------------------
 * 2022. 3. 11.    윤이준     최조 프로그램 작성
 *
 ****************************************************/
@Service
public class PrmtEmplAllwncMngServiceImpl implements PrmtEmplAllwncMngService {
	@Autowired
	private PrmtEmplAllwncMngMapper prmtEmplAllwncMngMapper;
	
	@Resource(name="userInfo")
	UserInfo userInfo;

	@Override
	public Map<String, Object> selectPrmtEmplAllwncList(PrmtEmplAllwncMngVO param) {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("list", prmtEmplAllwncMngMapper.selectPrmtEmplAllwncList(param));
		return result;
	}

	@Override
	@Transactional
	public String savePrmtEmplAllwncList(List<PrmtEmplAllwncMngVO> list) throws Exception {
		for(PrmtEmplAllwncMngVO param : list) {
			param.setAgenSeq( userInfo.getAgenSeq() );
			param.setEmplSeq( userInfo.getEmplSeq() );
			
			if( "U".equals( param.getCrudMode() ) ) {
				prmtEmplAllwncMngMapper.updatePrmtEmplAllwnc( param );
			}
		}
		
		return "정상적으로 저장되었습니다.";
	}
}