var isIE=("ActiveXObject" in window)	
var y=1;	
var msecsINIT=25;
var msecs=100;	//overridden in onload, and by Stop/Re-set Timer
var iDebug=0;
var iNumPerPage=200;

//for page load timings
var tStart;
var tEnd;

var bOutputGroupCols=false; //if false not outputted apart from the grouping columns.
var bTimerGoing=false;
var bErr=false;
var objX;

var objM; //json column mappings (created in render xsl) Not outputted - not used.

var a = [];	//column name object array. Populated from the cboOrder select in attachDivHdrs
var g = []; //group box array (holds dim.s for drag/drop)

//required to highlight the columns cbo without re-triggering the swap
var bSwapStarted=false;
var bIgnoreSwap=false;
var cboIdx=-1;

//grouping drag/drop variables 
var dv;
var target;
var gLastLenG=0; //track the number of groups - only recalc if a change in the number.
var gLastOneOver=-1; 
var gB4After=0; //so we know to insert b4 or after int above.
var gsLastDragOverMsg='';
var gsLastDragOverMsg2='';
var gsShowPipeMsg='';

//the only place where this is set
var xmlFileToUse='wipReport_vws.xml';	
	//xmlFileToUse='SongListGrouped_StDesc.xml'
	xmlFileToUse='custList.xml';
	xmlFileToUse='CustOrderSummary.xml';
	xmlFileToUse='songList.xml';

/*if the search param = below it is cleared for the first (sort) Xsl which normally 
  does the search as this value is only created by the final xsl	*/
const missingAttValue='{missing}'; 
	
function postInitJS(){
	// this is where we set any changes to the transformations to be done.
	// eg if the xml file is not 'custList.xml' we clear the group1 transform (both fetch and transform steps) to Z (skip)
	var xmlFName=getValue('xmlOrig','Url');
	if (xmlFName!='custList.xml'){		
		setStatus('xslGroup1','Z');
		setStatus('divGrp1Out','Z');
	}	
	
	if (xmlFileToUse=='songList.xml'){
		_('mainCaption').innerHTML='Jump the Shark - songlist mid 2022.';
	}
	if (xmlFileToUse=='CustOrderSummary.xml'){
		_('mainCaption').innerHTML='Northwind Sql Server - Customer Order Summary';
	}	
	if (xmlFileToUse=='custList.xml'){
		_('mainCaption').innerHTML='Northwind Sql Server - Customer List';
	}		
	if (xmlFileToUse=='wipReport_vws.xml'){
		_('mainCaption').innerHTML='AGRF Sales Data 2024';
	}	
	
	//and set the values of the informational page links
	_('hrefXmlOrig').innerHTML=xmlFName
	_('hrefXmlOrig').setAttribute('href',xmlFName);		
	
	var href=getValue('xslFinal','Url');
	_('hrefXslFinal').innerHTML=href
	_('hrefXslFinal').setAttribute('href',href);
}
function stopPropogation(e){
	e.cancelBubble = true;
	if(e.stopPropagation) { e.stopPropagation(); }
}
function setGrpDragDiv(dv,k){
	/*cout ('dv.addEventListener(2): k:'+k+' dv.id:'+dv.id);
	if (dv.id!='grp_p'+k){
		sh ('## setGrpDragDiv ##  k: '+k+' id: '+dv.id);
	}*/
	dv.addEventListener("dragstart", (ev) => {
	  // Change the source element's background color to show that drag has started
	  ev.currentTarget.classList.add("dragging");
	  // Clear the drag data cache (for all formats/types)
	  ev.dataTransfer.clearData();
	  // Set the drag's format and data.
	  // Use the event target's id for the data
	  ev.dataTransfer.setData("text/plain", ev.target.id);
	});
	dv.addEventListener("dragend", (ev) =>
		ev.target.classList.remove("dragging"),
	);
}
function attachDivHdrs(){
	//elUserName.addEventListener("mouseover", function(event){
	var divs = document.getElementsByTagName('div');
	for(var i=0; i<divs.length; i++) {
		if (divs[i].classList.contains('dvHdr')){  //.classList.contains('dvHdr') does not pick up dvHdrX
			if (divs[i].getAttribute('draggable') == 'true'){ 
				cout ('Draggable added to (1): '+divs[i].id,1);
				divs[i].onmouseover = function(e){ return eventBoxOpenerCloser(e, this, 1); }//Call opener/closer, passing the event (e), itself, and the "close" action
			}			
		}else{
			if (divs[i].classList.contains('dvHdrX')){  //.classList.contains('dvHdr') does not pick up dvHdrX
				if (divs[i].getAttribute('draggable') == 'true'){ 
					cout ('Draggable added to (2): '+divs[i].id);
					divs[i].onmouseover = function(e){ return eventBoxOpenerCloser(e, this, 1); }
				}			
			}
		}
	}
	//populateA();
	attachTgt();
	cout ('attachDivHdrs called');
}
function populateA(cbo){
	if (!cbo){
		cbo=_('cboOrder');
	}
	refreshA(cbo);
}
function refreshA(cbo){
	a.length=0;
	for (var i = 0; i < cbo.length; i++) {
		a[a.length] = { name: cbo.options[i].text, value: cbo.options[i].value };
	}	
}
function numGrps(){
	for (var i = 1; i < 5; i++) {
		pX=_('pipe'+i);
		if (!pX){
			return i-1;
		}
	}	
	return i;
}
function findLeft(el) {
  var rec = el.getBoundingClientRect();
  return rec.left + window.scrollX;
} 
function findTop(el) {
  var rec = el.getBoundingClientRect();
  return rec.top + window.scrollY;
} 
function misc(){
	var x=numGrps();
	if (x!=0){
		populateG();
	}
}
function populateG(){
	g.length=0;
	refreshG();
}
function refreshG(){
	var pX;
	var t,l,h,w;
	g.length=0;
	//pipes are 0-4 max. We look for 0-3/ie 1-4.
	for (var i = 1; i < 5; i++) {
		pX=_('pipe'+(i-1));
		if (!pX){
			return;
		}	
		pX=pX.nextElementSibling;
		if (!pX){
			/*if (i!=0){
				sh ('NOT FOUND!?'); //will happen whilst dragging
			}*/
			return;
		}
		l=parseInt(findLeft(pX));
		t=parseInt(findTop(pX));		
		w=parseInt(l+pX.offsetWidth);	
		h=parseInt(t+pX.offsetHeight);		
		g[g.length] = { X: l, Y: t, X2: w, Y2: h, ID: pX.id };
		sh ('populateG i: '+i+' X: '+l+' Y: '+t+' X2: '+w+' Y2: '+h+' ID: '+pX.id);
	}
}
function drag_over(ev){	
	var x=numGrps();	
	if (g.length==0){		
		if (x!=0){
			if (gLastLenG!=x){
				gLastLenG=x;
				refreshG();
				sh ('Len G now (1) '+g.length);
			}
		}
	}else{		
		sh ('numGrps '+x,1);
		if (x!=g.length){
			if (gLastLenG!=x){
				gLastLenG=x;
				refreshG();
				sh ('Len G now (3) '+g.length);
			}
		}		
	}

	var lenG=g.length;
	var x=parseInt(ev.clientX+window.scrollX);	
	var y=parseInt(ev.clientY+window.scrollY);	
	var w;
	var curK=0;
	var notSetB4After=0;
	for (var i = 0; i < lenG; i++) {
		//sh ('dragOver... X: '+g[i].X+' x: '+x+' X2: '+g[i].X2+'  Y: '+g[i].Y+' y: '+y+' Y2: '+g[i].Y2);
		if ((g[i].X<x && g[i].X2>x) && (g[i].Y<y && g[i].Y2>y)){			
			w=g[i].X2 - g[i].X; //width
			if ((x-g[i].X) < w/2){	//current pos - left, so how far across. Less than width/2?
				_('pipe'+i).nextElementSibling.style.backgroundColor='#ffdead';
				notSetB4After=1;
			}else{
				_('pipe'+i).nextElementSibling.style.backgroundColor='#deadff';
				notSetB4After=2;
				var nES1=_('pipe'+i).nextElementSibling.nextElementSibling;
				if (nES1){
					var nES2=nES1.nextElementSibling;
					if (nES2){
						nES2.style.backgroundColor='#ccef8d';		
					}
				}				
			}
			curK=i+1;
			gLastOneOver=curK;
			gB4After=notSetB4After;
			var sMsg2='drag_over - gLastOneOver (curK) set to '+gLastOneOver;
			if (gsLastDragOverMsg2!=sMsg2){
				sh (sMsg2);
				gsLastDragOverMsg2=sMsg2;
			}
			break;
		}else{
			if (_('pipe'+i)){
				if (_('pipe'+i).nextElementSibling){
					_('pipe'+i).nextElementSibling.style.backgroundColor='#ccef8d';			
				}
			}
		}
	}
	//if 4 groups then pipe0-pipe4. g.length==4.
	if (curK==0){
		if (_('pipe'+lenG)){
			setVis(_('pipe'+lenG),'visible',1); //right-most one
		}else{
			if (lenG!=0){
				if (_('pipe'+(lenG-1))){
					setVis(_('pipe'+(lenG-1)),'visible',1);
				}
			}
		}
	}else{
		if (notSetB4After==1){
			curK=curK-1;
		}
		for (var i = 0; i < lenG+1; i++) {
			if (i!=curK){
				if (_('pipe'+i)){
					setVis(_('pipe'+i),'hidden',1);
				}
			}
		}
		setVis(_('pipe'+curK),'visible',1);
	}
	var sMsg='End drag_over; gLastOneOver: '+gLastOneOver + ' gB4After: ' +gB4After;
	if (gsLastDragOverMsg!=sMsg){
		sh (sMsg);
		gsLastDragOverMsg=sMsg;
	}	
	ev.preventDefault();
}
function setVis(o,val,x){
	if (x==1){
		o.style.visibility=val;
	}else{
		if (val=='hidden'){
			o.style.color='#000099';
		}else{
			o.style.color='#990000';
		}
	}
}
function attachTgt(){
	target = document.querySelector("#target");
	target.addEventListener('dragover',drag_over,false); 
	target.addEventListener("drop", (ev) => {
		ev.preventDefault();
		// Get the data, which is the id of the source element
		const data = ev.dataTransfer.getData("text");		
		var pX=data.substring(4);	//grp_pX so pX only

		const source = document.getElementById(data);
		//gLastOneOver=0; gB4After (0,1,2)
		var bAddLast=true;
		var iNumChild=target.childElementCount;
		var info='';
		//sh('iNumChild: '+iNumChild+' gB4After: '+gB4After+' Len G:' + g.length);
		if (iNumChild!=0){		
			//we have id - is it already in the grp obj? If so is a simple swap.			
			var k=isInGrpObj(data);
			sh('isInGrpObj. data: '+data+' k: '+k+' gLastOneOver: '+gLastOneOver,1);
			if (k!=-1){
				if (gLastOneOver>0){
					//k may be incorrect so refresh (occurs if swapped multiple times as g[] is global)
					refreshG();
					k=isInGrpObj(data);
					sh ('Calling swapGrp.. (if diff.) gLastOneOver: '+gLastOneOver+' k: '+k);
					if (gLastOneOver!=k){
						swapGrp(gLastOneOver,k);
						sh ('Calling swapGrp.. (END)');
					}					
					return false;
				}			
			}	
			if (gB4After==1){
				info=' before group #'+ gLastOneOver;
				bAddLast=false;
				//we only modify the parameters and reload. Nope, we need to actually add for it to look ok.			
			} else{
				//gLastOneOver=gLastOneOver+1;
				sh ('gB4After: '+gB4After+' gLastOneOver: '+gLastOneOver+' g.length: '+g.length+' id: '+data);				
				if (gLastOneOver!=g.length){
					bAddLast=false;
				}
			}	            
		}
		sh ('##DROP## Pre addGrp bAddLast: '+bAddLast);
		//So if: drag_over; curK: 0 notSetB4After:1
		addGrp(pX);	
		if (bAddLast){     
			ev.target.appendChild(source); 
		}else{			
			//Order: caption, pipe1, group1, pipe2 etc
			var iChildElemNo;
			if (gLastOneOver<1){
				iChildElemNo=1;				
			}else{
				iChildElemNo = gLastOneOver * 2;
			}
			var refChild=ev.target.children[iChildElemNo];
			sh ('Inserting before child elem #: '+iChildElemNo);
			ev.target.insertBefore(source,refChild);
			
			if (gB4After==2){
				gLastOneOver=gLastOneOver+1;
			}		
			if (gLastOneOver!=-1){			
				//and swap the params			
				info=info+' Swapping grps #'+gLastOneOver+' with '+(g.length+1);
				sh (info);
				if (g.length!=0){
					if (gLastOneOver!=g.length+1){
						if (gLastOneOver!=0){
							swapGrp(gLastOneOver,g.length+1);
						}else{
							sh ('## Counts wrong?! ## gLastOneOver: '+gLastOneOver);
						}
					}
				}
			}
		}		
		if (gB4After==1){
			refreshG();
		}
		//clear globals.
		gLastOneOver=-1;
		gB4After=0;
		sh ('Group '+pX+' added.');		
	});
}
function isInGrpObj(id){
	var iRet=-1;
	for (var i = 0; i < g.length; i++) {
		if (g[i].ID==id){
			iRet=i+1;
			break;
		}
	}
	return iRet;
}
function eventBoxOpenerCloser(e,dv,k) {
	e = e || event;//Shorthand cross-browser way to refer to the (click) event.	
	stopPropogation(e);//Prevent events firing higher up in the DOM.
	//console.log ('post stopPropogation.');
	setGrpDragDiv(dv,k);
	return false;
};
function applyFilter(){	
	if (_('txtSearchBox').value==''){
		if (_('txtSearch').value==''){		
			return false;
		}
	}
	//so just clicking in and out with no change does not redo.
	if (_('txtSearch').value!=_('txtSearchBox').value){
		_('txtSearch').value=_('txtSearchBox').value;
		initTimer(1);
	}
}
function selectInCbo(s){
	var cbo=_('cboOrder');
	var len=cbo.options.length;
	for (var i = 0; i < len; i++) {
		if (cbo.options[i].text==s){
			cbo.selectedIndex=i;
			break;
		}
	}	
	return cbo.selectedIndex;
}
function findInCboUsingValue(cbo,p){
	p=p.substring(1);
	var len=cbo.options.length;
	var k=-1;
	for (var i = 0; i < len; i++) {
		if (cbo.options[i].value==p){
			k=i;
			break;
		}
	}	
	return k;
}
function findInCboUsingText(cbo,t){
	var len=cbo.options.length;
	var k=-1;
	for (var i = 0; i < len; i++) {
		if (cbo.options[i].text==t){
			k=i;
			break;
		}
	}	
	return k;
}
function changePage(k){
	_('currentPageNo').value=k;
	refreshA(_('cboOrder'));
	initTimer(1);
}
function resetPage(t){
	if (t.value!=iNumPerPage){	
		refreshA(_('cboOrder'));
		sh ('resetPage: '+t.value+' id: '+t.id)
		initTimer(1);
		iNumPerPage=t.value;
	}
}
function toggleGroupDisplay(chk){
	_('chkOutputGroupCols').checked=chk.checked;
	initTimer(2);
}
function toggleRowNumbers(chk){
	initTimer(2);
}
function thClick(me,p){
	if (!p){
		alert ('No "p" param!');
		return;
	}	
	_('lastClicked').value=p;
	var s='';
	var ds=me.getElementsByTagName('DIV');
	if (ds.length!=0){
		s=ds[0].innerHTML;
	}else{
		s=me.innerHTML;
	}
	cout('thClick p: '+p+' s:'+s);
	//s is the actual column name (not p1, etc)
	var dir='';
	if (me.className=='bth'){
		dir='asc';
	}
	if (me.className=='sortAsc'){
		dir='desc';
	}
	if (me.className=='sortDesc'){
		dir='asc';
	}	
	thClickCore(p,s,dir);
}
function addGrpCore(cbo,p,idx,z){	
	_('group'+z).value=p;
	// if it is the same as an existing sort clear the sort
	var y=z-1;
	var k=getMatchingSort(p,y);
	sh ('addGrpCore matching sort? k:'+k);
	var dir='asc';
	if (k>y){
		sh ('addGrpCore matching sort? here-1',1);
		if (k!=z){
			sh ('addGrpCore matching sort? here-2',1);
			dir=clearSortCore(k);	
		}else{
			sh ('addGrpCore matching sort? same');
			return;
		}
	}
	if (_('sort'+z).value!=''){
		bumpSort(z);
	}		
	_('sort'+z).value=p;
	_('sortDir'+z).value=dir;
}
function swapGrp(j,k,skipReload){
	var gJ=_('group'+j).value;
	var gJdir=_('sortDir'+j).value;
	_('group'+j).value = _('group'+k).value;
	_('sort'+j).value = _('group'+k).value;
	_('sortDir'+j).value = _('sortDir'+k).value
	_('group'+k).value = gJ;
	_('sort'+k).value = gJ;
	_('sortDir'+k).value = gJdir;	
	if (!skipReload){
		initTimer(1);
	}
}
function checkPipes(){
	for (var i = 1; i < 5; i++) {
		if (!_('pipe'+i)){
			return;
		}
	}
}
function addGrp(p){
	console.log('addGrp p:'+p);
	//we only need to make sure any sorts with no group are bumped up and the group added to the first available Group textbox
	var g1=_('group1').value;
	var g2=_('group2').value;
	var g3=_('group3').value;
	var g4=_('group4').value;
	cout('addGrp p:'+p+' g1:'+g1+' g2:'+g2+' g3:'+g3+' g4:'+g4);
	var cbo=_('cboOrder');
	refreshA(cbo);
	var idx=findInCboUsingValue (cbo,p);	
	console.log('idx:'+idx);
	var k=0;
	if (g1==''){
		addGrpCore(cbo,p,idx,1);
	}else{
		if (g2==''){
			addGrpCore(cbo,p,idx,2);	
		}else{
			if (g3==''){
				addGrpCore(cbo,p,idx,3);
			}else{
				if (g4==''){
					addGrpCore(cbo,p,idx,4);		
				}
			}
		}
	}
	if (!_('chkAutoOff').checked){
		initTimer(1);
	}
}
function removeGroup(me,k){
	var iNumFollowingGrps=0;
	//swap with any subsequent groups.
	for (var i = k + 1; i < 5; i++) {
		if ( _('group'+i).value!=''){
			iNumFollowingGrps=iNumFollowingGrps+1;
		}
	}
	var sort=_('sort'+k).value;
	var sortDir=_('sortDir'+k).value;
	sh ('RemoveGroup k: '+k +' iNumFollowingGrps: '+iNumFollowingGrps);
	if (iNumFollowingGrps!=0){	
		bumpGroupDown(k);
	}else{
		_('group'+k).value="";
	}		
	//me.parentNode.removeChild (me); No point - just refresh table. What if not auto-refreshing?
	if (!_('chkAutoOff').checked){
		initTimer(1);
	}
}
//so if 2 then 2 is made 3, 3 made 4.
function bumpGroupDown(k){
	for (var i = k; i < 4; i++) {
		var j=i+1;
		if (_('group'+ j).value!=''){
			sh('bumpGroupDown '+ j +' to '+i);
			_('sort'+i).value=_('sort'+ j).value;
			_('sortDir'+i).value=_('sortDir'+ j).value;
			_('group'+i).value=_('group'+ j).value;
		}else{			
			_('group'+ i).value='';
			_('sort'+i).value=_('sort'+ j).value;
			_('sortDir'+i).value=_('sortDir'+ j).value;			
		}
	}
	_('group4').value='';
	_('sort4').value='';
	_('sortDir4').value='';
}
function clearWarning(){
	tStart=Date.now();
	_('spnWarning').innerHTML='';
}
function setWarning(s){
	_('spnWarning').innerHTML=s;
}
function setMessage(s){
	_('spnInfo').innerHTML=s;
}
function cout(s,x){
	if (!x){
		console.log (s);
	}
}
function getMatchingSort(p,iMoreThan){
	console.log('getMatchingSort p: '+p+' iMoreThan: '+iMoreThan);
	var k=0;
	if (iMoreThan<1 && _('sort1').value==p){
		k=1;
	}
	if (iMoreThan<2 && _('sort2').value==p){
		k=2;
	}
	if (iMoreThan<3 && _('sort3').value==p){
		k=3;
	}
	if (iMoreThan<4 && _('sort4').value==p){
		k=4;
	}	
	cout ('getMatchingSort k: '+k);
	return k;
}
function thClickCore(p,s,dir){	
	sh('thClickCore p: '+p+' s: '+s+' dir: '+dir);
	_('xmlXslAuto').value='';
	_('xmlSorted').value='';	
	var idx=selectInCbo (s);	
	var lastSort1=_('sort1').value;
	var lastSort2=_('sort2').value;
	var lastSort3=_('sort3').value;
	var lastSort4=_('sort4').value;
	var lastSortDir1=_('sortDir1').value;
	var lastSortDir2=_('sortDir2').value;		
	var lastSortDir3=_('sortDir3').value;			
	var lastSortDir4=_('sortDir4').value;
	// No sort yet	
	// This could be far better - just flip dir. first. Then add if new. Or use a JSON object instead?
	cout ('s1: '+lastSort1+lastSortDir1+' s2: '+lastSort2+lastSortDir2+' s3: '+lastSort3+lastSortDir3);
	if (lastSort1==''){
		_('sort1').value=p;
		_('sortDir1').value=dir;	
	}else{
		if ((lastSort1==p) && (lastSortDir1!=dir)){
			_('sortDir1').value=dir;	
		}else{
			if (p==lastSort1){
				return;
			}
			if (lastSort2==''){
				_('sort2').value=p;
				_('sortDir2').value=dir;			
			}else{	
				if ((lastSort2==p) && (lastSortDir2!=dir)){
					_('sortDir2').value=dir;	
				}else{	
					if (lastSort2==p){		
						return;
					}else{	
						if (lastSort3==''){
							_('sort3').value=p;
							_('sortDir3').value=dir;	
						}else{
							if ((lastSort3==p) && (lastSortDir3!=dir)){
								_('sortDir3').value=dir;	
							}else{
								if (lastSort4==''){
									_('sort4').value=p;
									_('sortDir4').value=dir;	
								}else{
									if ((lastSort4==p) && (lastSortDir4!=dir)){
										_('sortDir4').value=dir;	
									}
								}							
							}
						}					
					}
				}
			}	
		}
	}
	initTimer(1);
}
function clearSingleSort(k,li){	
	var ul=_('ulSorts');
	var listLength = ul.children.length;
	if (ul.children[0].innerHTML=='No current sort.'){
		return false;
	}	
	var s=clearSortCore(k);	
	sh ('Sort k: '+k + ' dir: '+s+' removed.');
	initTimer(1);
}
//returns the dir of the first sort being cleared 
function clearSortCore(k){
	var s='';
	if (k==4){
		s=_('sortDir4').value;
		_('sort4').value='';
		_('sortDir4').value='';
		_('group4').value='';
	}
	if (k==3){
		s=_('sortDir3').value;
		_('sort3').value=_('sort4').value;
		_('sortDir3').value=_('sortDir4').value;
		_('group3').value=_('group4').value;
		clearSortCore(k+1);		
	}
	if (k==2){	
		s=_('sortDir2').value;			
		_('sort2').value=_('sort3').value;
		_('sortDir2').value=_('sortDir3').value;
		_('group2').value=_('group3').value;
		clearSortCore(k+1);	
	}	
	if (k==1){	
		s=_('sortDir1').value;
		_('sort1').value=_('sort2').value;
		_('sortDir1').value=_('sortDir2').value;
		_('group1').value=_('group2').value;
		clearSortCore(k+1);	
	}		
	return s;
}
function bumpSort(k){
	//so if 1 we go down to 1->2. if 4 we just set to grp4	
	if (k<4){
		_('sort4').value=_('sort3').value;
		_('sortDir4').value=_('sortDir3').value;
	}
	if (k<3){
		_('sort3').value=_('sort2').value;
		_('sortDir3').value=_('sortDir2').value;	
	}
	if (k<2){
		_('sort2').value=_('sort1').value;
		_('sortDir2').value=_('sortDir1').value;	
	}	
}
function clearParams(){	
	_('txtSearchBox').value='';
	_('lastClicked').value='';	
	_('currentPageNo').value='1';	//set to defaults
	_('numPerPage').value='200';	
	_('txtSearch').value='';
	_('chkHideRowNumbers').checked=true;
	for (var i = 1; i < 5; i++) {
		_('sort'+i).value='';
		_('sortDir'+i).value='';
		_('group'+i).value='';	
	}
	var row1 =_('tblRows').rows[0];
	var THs = row1.getElementsByTagName('TH');
	for (var i = 0; i < THs.length; i++) {
		THs[i].className='bth';
	}	
	var ul=_('ulSorts');
	var listLength = ul.children.length;
	ul.children[0].innerHTML='No current sort.';
	for (var i = 1; i < listLength; i++) {
		ul.removeChild(ul.children[1]);
	}	
	initTimer(0);
}
// Nice functionlity - but not used.
/*
function swapA(x){
	//[myArray[0], myArray[1]] = [myArray[1], myArray[0]];
	cout('swapA called: '+x);
	[a[x],a[x+1]]=[a[x+1],a[x]];
}
//return new index. 
function moveCore(cbo,idx,x){
	swapA(idx+x*-1 );
	if (x==1){
		idx=idx-1;
	}else{
		idx=idx+1;
	}
	rebindCbo(cbo,idx);	
	return idx;
}
function addItem(cbo,txt,value){
	cbo.options[cbo.options.length] = new Option(txt, value);
}
function rebindCbo(cbo,idx){
	clearCbo(cbo);
	bindCbo(cbo);	
	cbo.selectedIndex=idx;
}
function bindCbo(cbo){
	if (!cbo){
		cbo=_('cboOrder');
	}		
	var idx=cbo.selectedIndex;
	var idxVal=0;
	if (idx!=-1){
		idxVal=cbo.options[idx].value;
	}
	for (var i = 0; i < a.length; i++) {
		addItem(cbo,a[i].name,a[i].value);
	}
}
function clearCbo(cbo){
	if (!cbo){
		cbo=_('cboOrder');
	}	
	cbo.options.length=0;
}
 end unused functions */
function getNumGroups(){
	var k=0;
	if (_('group1').value!=''){
		k=1;
		if (_('group2').value!=''){
			k=2;
			if (_('group3').value!=''){
				k=3;
				if (_('group4').value!=''){
					k=4;
				}
			}
		}	
	}
	return k;
}
//called from the Up / Down buttons. 
function swap(selectId,x,doNotSetTimer){
	if (bIgnoreSwap || bSwapStarted){
		if (bSwapStarted){
			//setMessage ('Column change already in progress.. large dataset?'); //never displayed!! Overwritten immediately by next load
			cout('Column change already in progress.. large dataset?');
		}
		return;
	}	
	if (_('chkAutoOff').checked){
		doNotSetTimer=true;
	}else{
		bSwapStarted=true; //cleared by stopTimer
	}
	var cbo=_(selectId);
	if (cbo.selectedIndex==-1){
		if (cboIdx==-1){
			setWarning ('Nothing selected.');
		}
		return false;
	}
	var iNumGrps=getNumGroups();
	var idx=cbo.selectedIndex;
	//do toggle of first and last 2 instead.
	if (idx==0 && x==1){
		//setWarning ('Already in first position.');
		//return;
		x=0;
	}
	if (idx==cbo.options.length-1 && x==0){
		//setWarning ('Already in last position.');
		//return;		
		x=1;
	}	
	swapCbo(cbo,(x-1)*-1,doNotSetTimer);
}
function swapCbo(cbo,k,doNotSetTimer){
	if (bIgnoreSwap){
		return;
	}	
	var idx=cbo.selectedIndex;
	var len=cbo.options.length;
	sh('swap k: '+k+' cbo.selectedIndex: '+idx);	
	var mult=1;
	if (k==1){	
		if (cbo.selectedIndex==len-1){		
			idx=idx-1;
			cbo.selectedIndex=idx;		
		}
	}else{
		mult=-1;
		if (cbo.selectedIndex==0){		
			idx=idx-(1*mult);
			cbo.selectedIndex=idx;		
		}
	}	
	var v = cbo[idx].value;
	var t = cbo[idx].text;		
	//swap it	
	var v2 = cbo[idx+(1*mult)].value;
	var t2 = cbo[idx+(1*mult)].text;		
	//sh ('v:'+v+' v2:' + v2);
	cbo[idx].value=v2;
	cbo[idx].text=t2;
	cbo[idx+(1*mult)].value=v;
	cbo[idx+(1*mult)].text=t;	
	cboIdx=idx+(1*mult);
	populateA();
	if (!doNotSetTimer){	
		initTimer(2);
	}else{		
		setCboIdx();		
		//populateA(); //need?
	}	
}
function setCboIdx(){
	if (cboIdx==-1){
		return;
	}
	bIgnoreSwap=true;
	_('cboOrder').selectedIndex=cboIdx;
	cboIdx=-1;
	bIgnoreSwap=false;
}
function setSortStatusWrap(){
	setStatus ('xmlXslAuto','A');
	setStatus ('xmlSorted','A');
	setStatus ('divOut','A');
	sh ('setStatus called - xmlXslAuto, xmlSorted and divOut now all A');
}
function setOtherStatusWrap(){
	setStatus ('divOut','A');
	sh ('setStatus called - divOut now A');
}		
function setStatus(thisKey,newValue){
	var sRet='';
	for (const key in objX) {
		objX[key].forEach(item => {
			if (item.Key==thisKey){
				item.Status=newValue;
				sRet=item.Status;
			}
		});
	}
	return sRet;
}			
function getStatus(thisKey){
	var sRet='';
	for (const key in objX) {
		objX[key].forEach(item => {
			if (item.Key==thisKey){
				sRet = item.Status;
				//break; illegal!
			}
		});
	}
	return sRet;
}
function getValue(thisKey,strName){
	var sRet='';
	for (const key in objX) {
		objX[key].forEach(item => {
			if (item.Key==thisKey){
				sRet = item[strName];
				//break; illegal!
			}
		});
	}
	return sRet;
}
function initJS(initXml){
	objX = { 
		"Workflow": [ 
			{ 
				"Key" : "xmlOrig", 			//key is always the id of the textarea/div (aka 'target')
				"Needs" : "", 				//the keys (ie "Key" in this) of any required pre-requisite fields
				"Url" : initXml,			//relative url. If blank url it is assumed to be a transformation
				"Status": "A",				//A, B, C, D for not started, in progress, successfully completed, failed, and Z not needed (skipped until cleared).				
				"TargetIsTextArea": "Y"		//Only req. if transformation (determines append vs. value)
			}, 
			{ 
				"Key" : "xslFinal", 	
				"Needs" : "", 		
				"Url" : "xslt_Test_Grp.xsl",		
				"Status": "A",
				"TargetIsTextArea": "Y"
			}, 		
			{ 
				"Key" : "xslGroup1", 	
				"Needs" : "", 		
				"Url" : "autoSummary.xsl",			
				"Status": "A",
				"TargetIsTextArea": "Y"
			},
			{ 
				"Key" : "divGrp1Out", 	
				"Needs" : [ "xmlOrig", "xslGroup1" ], 		
				"Url" : "",	
				"Status": "A",
				"TargetIsTextArea": "N"
			},  
			{ 
				"Key" : "xslAutoInit", 	
				"Needs" : "", 						
				"Url" : "autoGenRev_xsl_srch.xslt",				
				"Status": "A",
				"TargetIsTextArea": "Y"
			},
			{ 
				"Key" : "xmlXslAuto", 	
				"Needs" : [ "xmlOrig", "xslAutoInit" ], 		
				"Url" : "",			
				"Status": "A",
				"TargetIsTextArea": "Y",
				"Control": [ "sort1", "txtSearch", "numPerPage" ],	//if all the named controls are empty perform the copy in the Fallback, else perform transform. As now also doing paging in sort xsl they never will be.
				"Params": "getParamArray",
				"Fallback": [ "xmlOrig", "xmlSorted" ],	
				"PostTransformReplace": [							//This is needed due to deficiencies with the way the XslProcessor performs alias-transform. Should not be required.
					{
						"pre": 'Transform-alias', 
						"post": 'Transform'
					},
					{
						"pre": '__CR__', 
						"post": ''
					},
					{
						"pre": ':xyz', 
						"post": ':xsl'
					},
					{
						"pre": 'xyz:', 
						"post": 'xsl:'
					},					
					{
						"pre": 'xmlns__msxsl', 
						"post": 'xmlns:msxsl'
					},
					{
						"pre": 'xmlns__exslt', 
						"post": 'xmlns:exslt'
					},
					{
						"pre": 'msxsl__script', 
						"post": 'msxsl:script'
					}							
				]
			}, 		
			{ 
				"Key" : "xmlSorted", 	
				"Needs" : [ "xmlOrig", "xmlXslAuto" ], 		
				"Url" : "",			
				"Status": "A",
				"TargetIsTextArea": "Y"
			}, 						
			{ 
				"Key" : "divOut", 	
				"Needs" : [ "xmlSorted", "xslFinal" ], 		
				"Url" : "",							
				"Status": "A",
				"Params": "getParamArray",
				"TargetIsTextArea": "N"
			}
		] 
	};	
}
function loopIt(){
	y++;
	var sRet='';
	var sKey='';
	var bOk=true;	
	var allDone=true;
	for (const key in objX) {
		objX[key].forEach(item => {
			sKey=item.Key;	
			if (item.Status!='Z') { //so not skipping
				if (item.Url!='') { //so is a fetch of a file
					if (item.Status=='A'){	
						allDone=false;
						if (item.Needs.length!=0){
							for (let i = 0; i < item.Needs.length; i++) {
								sh ('\t\t\t'+item.Needs[i]);
								if (item.Needs[i]!=''){
									sRet=getStatus(item.Needs[i]);									
									if (sRet!='C'){
										bOk=false;
										break;
									}
								}
							}	
							if (bOk){							
								if (populateTA(item.Url,sKey)){
									item.Status='C';
								}else{
									sh (sKey+' status now '+item.Status);
								}
							}
						}else{										
							if (populateTA(item.Url,sKey)){
								item.Status='C';
							}else{
								sh ('\t'+sKey+' No needs - status should now be B. Actual: '+item.Status);								
							}
						}				
					}else{					
						//still working.
						if (item.Status=='B'){
							allDone=false;	
						}
					}
				}else{
					sh ('\t\t #### Key: '+item.Key+' Status: '+ item.Status);
					if (item.Status=='A'){			
						allDone=false;											
						/*
						//if the named control is empty perform the copy in the Fallback, else check Needs and perform transform
						"Control": "sort1",			
						"Fallback": [ "xmlOrig", "xmlSorted" ]							
						*/	
						//should throw error if Control present and blank, or no control exists with this id.												
						//if Control present check this first. If no value found then no need to check "Needs"
						var iNonBlankCount=0;
						if (item.Control){
							for (let i = 0; i < item.Control.length; i++) {
								if (_(item.Control[i]).value!=''){
									iNonBlankCount=1;
									break;
								}
							}
						}						
						if (item.Control && iNonBlankCount==0){	
							var sFrom, sTo;
							for (let i = 0; i < item.Fallback.length; i++) {
								if (i==0){
									sFrom=item.Fallback[0];
								}else{
									sTo=item.Fallback[1];
								}
							}
							if (sTo!='' && sFrom!=''){
								if (populateTAcheck(sFrom)){
									_(sTo).value=_(sFrom).value;
									item.Status='Z';
									sh ('\t'+item.Key+' status now (2) '+item.Status,1);
									setStatus(sTo,'C');																			
									sh ('\t'+sTo+' status now (2) C',1);		
								}
							}	
						}else{
							//there is is a non-blank value, or no Control. Same result either way.
							if (item.Needs.length!=0){
								for (let i = 0; i < item.Needs.length; i++) {
									if (item.Needs[i]!=''){
										sRet=getStatus(item.Needs[i]);								
										if (sRet!='C'){
											bOk=false;
											break;
										}
									}
								}	
								if (bOk){								
									item.Status='B';
									sh ('\t'+item.Key+' status now (3) '+item.Status);	
									var params=null;
									var z=0;
									//bespoke logic for missing att search. (ie can't search in the sort as they haven't yet been replaced in it)
									if (item.Key=='xmlXslAuto'){
										z=1;
									}									
									if 	(item.Params){					//"Params": "getParamArray"
										params=this[item.Params](z); 	//damn I like this! https://stackoverflow.com/questions/43726544/how-to-call-a-function-using-a-dynamic-name-in-js
									}	
									if (item.PostTransformReplace) {
										var a2 = [];
										sh ('PostTransformReplace present. '+sKey);
										/* This is any string replaces that need to be done after the transformation result is returned*/	
										item.PostTransformReplace.forEach(itm => {
											a2[a2.length] = { name: itm.pre, value: itm.post };
										});
										if (a2){
											for (var i = 0; i < a2.length; i++) {
												sh('Replace '+a2[i].name+' with '+ a2[i].value,1);	
											}		
										}						
									}										
									stdXmlXslOut(item.Needs[0],item.Needs[1],sKey,params,a2);			
								}	
							}else{										
								item.Status='B';
								sh ('\t'+sKey+' No needs - status now B');										
							}							
						}
					}else{	
						//still doing work.
						if (item.Status=='B'){
							allDone=false;	
						}
					}
				}
			}					
		});
		if (allDone){
			sh (' ** FIN **');			
			tEnd = Date.now();
			var durationMSecs = tEnd - tStart ;	
			setWarning ('Page loaded in '+durationMSecs+' msecs.');
			stopTimer();
		}		
		if (bErr){
			stopTimer();
			setWarning ('Error occurred. No further details. bErr indicates non-existant control name.');
		}
	}		
}
function initTimer(x,bodyLoad){
	if (bTimerGoing){
		sh (' ### Timer already going ###');
		return;
	}
	if (bodyLoad){
		msecs=msecsINIT;
		tStart=Date.now();
		initJS(xmlFileToUse);
		postInitJS();
		sh (' ### timer initialised (bodyLoad) ### msecs: ' + msecs+'  xml file: '+xmlFileToUse);
	}else{
		clearWarning();
		if (x==1){
			setSortStatusWrap();			
		}
		if (x==2){
			setOtherStatusWrap();
		}
		if (x==0){
			setSortStatusWrap();	
			setOtherStatusWrap();
		}
		sh (' ### timer initialised ### msecs: ' + msecs+' x: '+x );
	}
	myTimeout = setInterval(timerOut, msecs);	
	bTimerGoing=true;
}
function stopTimerX(btn) {
	if (btn.value=="Re-set"){
		btn.value='Stop timer'
		msecs=msecsINIT;
		setWarning('Timer re-started using default value of '+msecsINIT+'msecs.');
	}else{
		bTimerGoing=false;
		msecs=9999;
		sh ('Stop Timer called (X).');
		clearTimeout(myTimeout);
		btn.value="Re-set" //no need
		setWarning('Click Re-set and change any value, or perform an action to re-start.');
	}
}
function toggleDisplay(s){
	//divGrp1Out
	//alert (s);
	if (_(s).style.display=='none'){
		_(s).style.display='';
	}else{
		_(s).style.display='none';
	}
	return false;
}
function checkSummaryGrpDivs(){
	//show toggleDisplay href if data present
	var dG1= _('divGrp1Out');
	if (dG1){
		if (_('divGrp1Out').innerHTML==''){
			_('tdGrp1Out').style.display='none';
		}else{
			_('tdGrp1Out').style.display='';
			_('tdGrp1Out').style.visibility='visible';
		}
	}
	var dG2= _('divGrp2Out');
	if (dG2){
		if (_('divGrp2Out').innerHTML==''){
			_('tdGrp2Out').style.display='none';
		}else{
			_('tdGrp2Out').style.display='';
			_('tdGrp1Out').style.visibility='visible';
		}	
	}
}
function stopTimer() {	
	sh ('Stop Timer called.');
	clearTimeout(myTimeout);
	//re-highlight correct cbo
	setCboIdx();	
	bSwapStarted=false;
	checkSummaryGrpDivs();
	bTimerGoing=false;
}
function timerOut() {
	sh (' ### timer called ### '+y);
	loopIt();
}
function sh(s,skip){
	if (!skip){
		const d = new Date();
		let t = d.toISOString();//Time is GMT?
		t=jsReplace(t,'Z','');
		t=jsReplace(t,'T',' ');
		var taH=_("taHistory");
		taH.value=">> "+t+" " +s+"\n"+taH.value;
	}
}
function sortsExist(){
	var s1=_('sort1').value;
	if (s1!=''){
		return true;
	}
	return false;
}
function stdXmlXslOut(xmlTAid,xslTAid,tgt,params,a){
	sh('stdXmlXslOut: '+xmlTAid+' '+xslTAid+' '+tgt);
	var xml=_(xmlTAid).value;
	var xsl=_(xslTAid).value;	//textContent?
	var k=xsl.indexOf(' < ');
	if (k!=-1){
		cout ('xsl.substring(k-5,20) '+xsl.substring(k-5,20));
		xsl=jsReplace(xsl,' < ',' &lt; ');
	}
	if (xsl.indexOf(' > ')!=-1){
		xsl=jsReplace(xsl,' > ',' &gt; ');
	}	
	
	if (xsl.indexOf(' < ')!=-1){
		sh ('Found open angle bracket - NOT FIXED.');
	}	
	if (xsl.indexOf(' > ')!=-1){
		sh ('Found close angle bracket - NOT FIXED.');
	}		
	new Transformation().setXml(xml).setXslt(xsl).transform(tgt,params,a);
}
function forceInt(id,defNumber){
	var x=_(id).value;
	x=x.trim();
	x=jsReplace(x,' ','');
	if (x==''){
		_(id).value=defNumber;
	}else{
		var y=parseInt(x);
		if ((y+'')!='NaN'){
			_(id).value=y;
		}else{
			_(id).value=defNumber;
		}	
	}
}
function getParamArray(k){
	var sort1=_('sort1').value;
	var sort2=_('sort2').value;
	var sort3=_('sort3').value;
	var sort4=_('sort4').value;
	var sortDir1=_('sortDir1').value;
	var sortDir2=_('sortDir2').value;
	var sortDir3=_('sortDir3').value;
	var sortDir4=_('sortDir4').value;
	var search=_('txtSearch').value;	
	var dbg=false;		
	if (_('chkDebug').checked){
		dbg=true;
	}
	var outputGroupCols=false;	
	if (_('chkOutputGroupCols').checked){
		outputGroupCols=true;
	}
	var hideRowNumbers=false;	
	if (_('chkHideRowNumbers').checked){
		hideRowNumbers=true;
	}	
	
	var p = [];	
	p[p.length] = { name: 'sort1', value: sort1 };
	p[p.length] = { name: 'sortDir1', value: sortDir1 };
	p[p.length] = { name: 'sort2', value: sort2 };
	p[p.length] = { name: 'sortDir2', value: sortDir2 };
	p[p.length] = { name: 'sort3', value: sort3 };
	p[p.length] = { name: 'sortDir3', value: sortDir3 };
	p[p.length] = { name: 'sort4', value: sort4 };
	p[p.length] = { name: 'sortDir4', value: sortDir4 };
	
	var group1=_('group1').value;
	var group2=_('group2').value;
	var group3=_('group3').value;
	var group4=_('group4').value;
	//first x groups = first x sorts
	p[p.length] = { name: 'group1', value: group1 };
	p[p.length] = { name: 'group2', value: group2 };
	p[p.length] = { name: 'group3', value: group3 };	
	p[p.length] = { name: 'group4', value: group4 };						

	if (k==1 && search==missingAttValue){
		p[p.length] = { name: 'search', value: '' };
	}else{
		p[p.length] = { name: 'search', value: search };
	}
	if (dbg){
		p[p.length] = { name: 'debug', value: 'Y' };
	}else{
		p[p.length] = { name: 'debug', value: 'N' };
	}
	if (outputGroupCols){
		p[p.length] = { name: 'outputGroupCols', value: 'Y' }; //default ''
	}	
	if (hideRowNumbers){
		p[p.length] = { name: 'hideRowNumbers', value: 'Y' };  //default ''
	}		
		
	p[p.length] = { name: 'lastClicked', value: _('lastClicked').value };	
	
	forceInt('currentPageNo',1);
	p[p.length] = { name: 'pageNo', value: _('currentPageNo').value };
	
	forceInt('numPerPage',210);
	p[p.length] = { name: 'numPerPage', value: _('numPerPage').value };
	
	var s='|';
	var cbo=_('cboOrder');
	if (cbo){		
		cout ('Pre columnMappings len (cbo): '+cbo.length,1)
		if (cbo.length > 915){
			cout (a);
		}
		for (var i = 0; i < cbo.length; i++) {
			var idx=cbo[i].value;
			if (idx!=i+1){ 
				var j=i+1;
				s=s+j+'^'+idx+'|';
			}	
		}		
		p[p.length] = { name: 'columnMappings', value: s };
		if (s!='|'){
			sh ('Param: columnMappings: '+s);
		}
		
	}else{
		p[p.length] = { name: 'columnMappings', value: s };
	}
	return p;
}
function populateTAcheck(id){	
	var test=_(id).value;
	if (test!=''){	
		return true;
	}	
	return false;
}
function DIVcheck(id){
	var test=_(id).innerHTML;
	if (test!=''){	
		return true;
	}	
	if (id=='divGrp1Out'){
		sh ('No innerHTML for '+id+'?!');
	}
	return false;
}
//	Xml: current relative filename. 
// 	 id: id of target textarea
function populateTA(Xml,id){
	sh ('populateTA: '+id);
	var test=_(id).value;
	if (test!=''){
		//this should not be getting called when already populated?
		sh ('Already populated! '+id);
		return true;
	}	
	setStatus(id,'B');
	//var _xm = { readyState: 4 }; this does/did what?
	var xm = new XMLHttpRequest();
	sh ('fetching xml.. '+Xml);
	xm.m = id;
	xm.onreadystatechange = function() {
		var x, m, xmlDoc;
		x = this;
		m = x.m;
		if ((x.readyState == 4) && (x.status == 200)){
			if (x.responseXML != null)
				xmlDoc = x.responseXML;
			else {
				var parser = new DOMParser();
				xmlDoc = parser.parseFromString(x.responseText, "application/xml");
			}	
			if (xmlDoc){
				var s = new XMLSerializer();
				var newXmlStr = s.serializeToString(xmlDoc);	
				sh ('fetch complete  id: '+m);	
				if (!_(m)){
					//alert ('yo! m:'+m);
					bErr=true;
					return;
				}
				_(m).value=newXmlStr;		
				setStatus(m,'C');	
			}else{
				sh ('Unable to retrieve the xml: '+m);
			}	
		}
	};		
	
	try {
		xm.open("GET", Xml, true);
	}
	catch (e) { alert(e) }
	xm.send(null);		

}
function jsReplace(txt,t1,t2){
	if (typeof(txt)=="undefined"){
		return "";
	}
	txt=txt+'';
	var iPos=txt.indexOf(t1);
	if (iPos==-1){
		return txt;
	}
	var iLenA=t1.length;
	var txtA='';
	txtA=txt;
	var txtKeep='';
	while(txtA.indexOf(t1)!=-1) {
		var iNext=txtA.indexOf(t1);
		txtKeep=txtKeep+txtA.substring(0,iNext)+t2;
		txtA=txtA.substring(iNext+iLenA);
	}
	return txtKeep+txtA;
}
function _(x){
	return document.getElementById(x);
}	
function Transformation() {
    var xml;    
    var xmlDoc;    
    var xslt;    
    var xsltDoc;
    var transformed = false;        
    this.getXml = function() {
        return xml;
    }
    this.getXmlDocument = function() {
        return xmlDoc
    }
    this.setXml = function(x) {
        xml = x;
        return this;
    }
    this.getXslt = function() {
        return xslt;
    }
    this.getXsltDocument = function() {
        return xsltDoc;
    }
    this.setXslt = function(x) {
        xslt = x;
        return this;
    }    
    this.getCallback = function() {
        return callback;
    }
    this.setCallback = function(c) {
        callback = c;
        return this;
    }
	//was: = function(target, postTransform) 
    this.transform = function(target, params, a2) {
        if (!browserSupportsXSLT()) {
            alert('This browser does not support XSLT in javascript, so we cannot continue, sorry.')
            return;
        }
        var str = /^\s*</;
        var t = this;
        var transformed = false;
        var xm = {
            readyState: 4
        };
        var xs = {
            readyState: 4
        };	
        if (isIE) {
			alert ('IE is no longer supported. Sorry.');
			return;
        }       
		var change = function() {
			if (xm.readyState == 4 && xs.readyState == 4 && !transformed) {
				if (xm.responseXML != null)
					xmlDoc = xm.responseXML
				else {
					var parser = new DOMParser();
					xmlDoc = parser.parseFromString(xm.responseText, "application/xml");
				}		
				if (xs.responseXML != null)
					xslDoc = xs.responseXML
				else {
					var parser = new DOMParser();
					xslDoc = parser.parseFromString(xs.responseText, "application/xml");
				}	
				var resultDoc;
				var processor = new XSLTProcessor();
				if (typeof processor.transformDocument != 'function') {		
					try{
						processor.importStylesheet(xslDoc);
					} catch (error) {
						console.log('err=' + error);
						return false;
					}					
					if (params){
						for (var i = 0; i < params.length; i++) {
							if (params[i].name=='columnMappingsXX'){
								cout(params[i].name+': '+params[i].value);
							}						
							processor.setParameter(null, params[i].name, params[i].value);	
						}		
					}		
					if (target=="xmlSorted"){		
						//debugger
						resultDoc = processor.transformToDocument(xmlDoc);				
					}else{
						//NB all attribute names become lcase
						resultDoc = processor.transformToFragment(xmlDoc, document);
					}								
					if (!resultDoc){
						debugger
						sh ('### CALL FAILED ###  retrying?? ' + target)
						return;						
					}	
						
					//we have the target (key)	
					var TargetIsTextArea=getValue(target,"TargetIsTextArea");	
					sh ('TargetIsTextArea: '+TargetIsTextArea,1);
					if (TargetIsTextArea=="Y"){					
						var s = new XMLSerializer();
						var xmlStr = s.serializeToString(resultDoc);	
						//we could have possibly left this hardcoded as it is basically a one-off 'fix'
						/*
						if (target=='xmlXslAuto'){
							xmlStr=jsReplace(xmlStr,'Transform-alias','Transform');
							xmlStr=jsReplace(xmlStr,'___','');
							xmlStr=jsReplace(xmlStr,'xyz','xsl');	
						}*/		
						if (a2){
							for (var i = 0; i < a2.length; i++) {
								xmlStr=jsReplace(xmlStr,a2[i].name,a2[i].value);	
							}		
						}							
						_(target).value=xmlStr;
					}else{					
						_(target).innerHTML = '';	
						try {
						  _(target).appendChild(resultDoc);
						} catch (e) {
						  console.log('err=' + e);
						}
					}
					setStatus(target,'C');	
				}
				transformed = true;
			}
		};
        		
        if (str.test(xml)) {
            xm.responseXML = new DOMParser().parseFromString(xml, "text/xml");			
        }
        else {		
			//can get from web server?
            xm = new XMLHttpRequest();
            xm.onreadystatechange = change;
            try {
                xm.open("GET", xml, true);
            }
            catch (e) { alert(e) }
            xm.send(null);			
        }
        if (str.test(xslt)) {
            xs.responseXML = new DOMParser().parseFromString(xslt, "text/xml");            
        }else{
			//can get xslt from web server?
            xs = new XMLHttpRequest();
            xs.onreadystatechange = change;
            try {
                xs.open("GET", xslt, true);
            }
            catch (e) { 
				console.log('err=' + e);
			}
            xs.send(null);			
        }
		change();
    }
}

//https://developer.mozilla.org/en-US/docs/Web/XML/Parsing_and_serializing_XML
/*
fetch("example.xml")
  .then((response) => response.text())
  .then((text) => {
    const parser = new DOMParser();
    const doc = parser.parseFromString(text, "text/xml");
    console.log(doc.documentElement.nodeName);
  });
*/

/**
 * Returns whether the browser supports XSLT.
 * @return the browser supports XSLT
 */
function browserSupportsXSLT() {
    var support = false;
    if (isIE) { // IE 5+
        support = true;
    }
    else if (window.XMLHttpRequest != undefined && window.XSLTProcessor != undefined) { // Mozilla 0.9.4+, Opera 9+
       var processor = new XSLTProcessor();
       if (typeof processor.transformDocument == 'function') {
           support = window.XMLSerializer != undefined;
       }
       else {
           support = true;
       }
    }
    return support;
}		
function goTo(){
	_('numPerPage').value=iNumPerPage;
	document.location="#topTbl";
}
/* grouping actions (collapse, expand etc) */
function checkIt(tr,k,clsName,newVal){			
	if (!tr){
		return false;
	}else{
		var td=tr.getElementsByTagName('TD');
		if (td.length!=0){
			if (td[k]){
				if (td[k].className.indexOf(clsName)==0){
					tr.style.display=newVal;
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}
	}
}	
function checkNS(tr){			
	if (!tr){
		return false;
	}else{
		return true;
	}
}			
function toggleGrp(td){
	var tr=td.parentNode;
	var cname=td.className; 
	var k = getPrevSiblingCount(td);
	var bMore=false;
	var z=0;
	var trOne;
	var newVal='';
	trOne=tr.nextElementSibling;
	if (trOne.style.display==''){
		newVal='none';
	}			
	do {
		tr=tr.nextElementSibling;
		bMore=checkIt(tr,k,cname,newVal);		
		z++;
		if (z>299){
			alert ('loop..');
			return;
		}
	} while (bMore);
	return;			
}
function getPrevSiblingCount(cnt){
	var k=0;
	do{		
		cnt=cnt.previousElementSibling;
		if (cnt){		
			k++;
		}				
	}
	while (cnt)
	return k;
}
function toggleGrpAll(tdIn,x){
	if (tdIn.tagName=='DIV'){
		tdIn=tdIn.parentNode;
	}
	var k = 0; //getPrevSiblingCount(tdIn);
	k=x-1;
	var clsName='';
	var newVal='';
	var tr=tdIn.parentNode;
	var z=0;
	do {
		tr=tr.nextElementSibling;
		bMore=checkNS(tr);	
		if (bMore){
			if (clsName==''){
				var td=tr.getElementsByTagName('TD');
				if (td[k]){
					if (td[k].innerHTML.indexOf('+')!=-1){								
						clsName=td[k].className;
						tr=tr.nextElementSibling;
						if (tr.style.display==''){
							newVal='none';
						}	
						tr.style.display=newVal;
						cout(`#`+k+` td Len: `+td.length+' newVal: '+newVal);
						bMore=false;
					}
				}						
			}
		}
		z++;
		if (z>299){
			alert ('loop..');
			return;
		}
	} while (bMore);
	
	//just cycle through
	var cname=clsName.substring(0,3);
	var tbl=tdIn.parentNode.parentNode;
	var t=tbl.getElementsByTagName('TR');
	//alert (t.length);
	for (let i = 0; i < t.length; i++) {
		td=t[i].getElementsByTagName('TD');
		if (td[k]){
			if (td[k].innerHTML.indexOf('+')==-1){
				if (td[k].className.indexOf(cname)==0){
					t[i].style.display=newVal;
				}
			}else{
				if (newVal=='' && t[i].style.display!=newVal){
					t[i].style.display=newVal;
				}
			}
		}
		//console.log(`#`+k+` td len:`+td.length);
	}
	return;				
}