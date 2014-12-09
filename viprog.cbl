	identification division.
	program-id.
		mits01ca.

      ******************************************************************
      * MITS01CA
      * Print program for the UPDATE. It shows a break down money into
      * specified categories. It calculates Net Pay and reconciles against
      * data code 948.
      * just added this line as a test
      * and added this one on the remote
      ******************************************************************

	environment division.
	configuration section.
	source-computer.
		unix-v5.
	object-computer.
		unix-v5.
	special-names.
		currency sign is "#".

      ******************************************************************
      //////////////////////////////////////////////////////////////////
	input-output section.

	file-control.

		copy "fa.fc".
		copy "fb.fc".
		copy "fe.fc".
		copy "fj.fc".
		copy "fu.fc".
		copy "fv.fc".
	 	copy "fy.fc".
		copy "fz.fc".
		copy "fzc.fc".
		copy "fze.fc".
		copy "fzf.fc".
		copy "fzl.fc".
		copy "fzq.fc".

		select paa-prt-fl
			assign to external PRINT
			organization is line sequential
			file status is wzz-file-status.

		select fa-pay-fl
			assign to external SUBDPAY
			organization is indexed
			access mode is dynamic
			record key is fa-key
			file status is wzz-file-status.

		select fb-pay-fl
			assign to external DEPTPAY
			organization is indexed
			access mode is dynamic
			record key is fb-key
			file status is wzz-file-status.

		select fc-pay-fl
			assign to external PRPAY
			organization is indexed
			access mode is dynamic
			record key is fc-key
			file status is wzz-file-status.

		select fd-summ-fl
			assign to external SUMMARY
			organization is indexed
			access mode is dynamic
			record key is fd-key
			file status is wzz-file-status.

		select ff-coinage-fl
			assign to external COINAGE
			organization is indexed
			access mode is dynamic
			record key is fcf-key
			file status is wzz-file-status.

		select ft-tran-fl
			assign to external TRANCOPY
			organization is indexed
			access mode is dynamic
			record key is ftr-key
			file status is wzz-file-status.

      ******************************************************************
      //////////////////////////////////////////////////////////////////
	data division.

	file section.

		copy "fa.fd".
		copy "fab.rec".
		copy "fb.fd".
		copy "fbb.rec".
	 	copy "fe.fd".
	01 feb-rec.
	    03 filler				pic x(38).
	    03 feb-ctx.
		05 feb-ct			pic 9(2).

		copy "fj.fd".
		copy "fu.fd".
		copy "fub.rec".
		copy "fv.fd".
		copy "fvb.rec".
	 	copy "fy.fd".
		copy "fyb.rec".
		copy "fz.fd".
		copy "fzc.fd".
		copy "fzcb.rec".
		copy "fze.fd".
		copy "fzf.fd".
		copy "fzl.fd".
		copy "fzq.fd".
		copy "fzqb.rec".
		copy "fzqc.rec".

	fd paa-prt-fl.

	01 paa-print-line			pic x(132).

	fd fa-pay-fl.
	01 fa-pay-record.
	    03 fa-key				pic x(4).
	    03 fa-pay-rec.
		05 filler			pic x.
		05 fa-desc-code			pic x(4).
		05 filler			pic x.
		05 fa-desc-name			pic x(18).
		05 fa-rec-type			pic x.
		05 fa-data.
		    07 fa-data-col	occurs 6.
			09 filler		pic s9(12).

	fd fb-pay-fl.

	01 fb-pay-record.
	    03 fb-key				pic x(4).
	    03 fb-pay-rec.
		05 filler 			pic x(6).
		05 fb-desc-name			pic x(18).
		05 fb-rec-type			pic x.
		05 fb-data.
		    07 fb-data-col	occurs 6.
			09 filler		pic s9(12).

	fd fc-pay-fl.

	01 fc-pay-record.
	    03 fc-key				pic x(4).
	    03 fc-pay-rec.
		05 filler			pic x(6).
		05 fc-desc-name			pic x(18).
		05 fc-rec-type			pic x.
		05 fc-data.
		    07 fc-data-col	occurs 6.
			09 filler		pic s9(12).

	fd fd-summ-fl.

	01 fd-summ-record.
	    03 fd-key.
		05 fd-td			pic x(3).
		05 fd-ref			pic x(7).
	    03 fd-amounts.
		05 fd-amt			pic s9(12) occurs 16.

	fd ff-coinage-fl.

	01 ff-coinage-record.
	    03 fcf-key				pic x(20).
	    03 fcf-cash				pic 9(12).
	    03 fcf-amounts.
		05 fcf-amt			pic 9(5) occurs 11.

	fd ft-tran-fl.

	01 ft-tran-record.
	    03 ftr-key				pic x(20).

      ******************************************************************
      //////////////////////////////////////////////////////////////////
	working-storage section.

	copy "wzz.ws".
	copy "wza.ws".
	copy "fac.rec".
	copy "fzlb.rec".

       01  wa-prog-ref                        pic x(20) value
           "mits01ca-$Rev: 45 $".

       01  wa-what-string                     pic x(52) value
           "@(#)$Id: mits01ca.cbl 45 2011-01-07 14:38:55Z gqtp $>".

	01 wa-use-nicalc5-date			pic x(8) value
		"20030406".

	01 waa-scan				pic 9 value zero.

	01 waa-last-key				pic x(20).

	01 waa-tag-key.
	    03 waa-tk-dept.
		05 waa-tk-dept-char		pic x occurs 6.
	    03 waa-tk-cost-code.
		05 waa-tk-cc-char		pic x occurs 12.
	    03 waa-tk-employee			pic x(8).
	    03 waa-tk-sub-dept			pic x(6).
	    03 filler				pic x(6).
	    03 waa-tk-ctx.
		05 waa-tk-ct			pic 9(2).

	01 waa-flags.
	    03 waa-1c.
		05 waa-1n			pic 9.
	    03 waa-special-split		pic 9.
	    03 waa-fzq-present			pic 9.
	    03 waa-cost-found			pic 9.
	    03 waa-cost-break			pic 9.
	    03 waa-code-break			pic 9.
	    03 waa-end-totes			pic 9.
	    03 waa-thrown			pic 9.
	    03 waa-laser-throw			pic 9.
	    03 waa-grp-prints.
		05 waa-grp1-prted		pic 9.
		05 waa-grp2-prted		pic 9.
		05 waa-grp3-prted		pic 9.
		05 waa-grp4-prted		pic 9.
		05 waa-grp5-prted		pic 9.
		05 waa-grp6-prted		pic 9.
	    03 waa-special-prt			pic 9.
	    03 waa-summ-flag			pic 9.
	    03 waa-tran-new			pic 9.
	    03 waa-add-sub-flag			pic 9.
	    03 waa-notion-flag			pic 9.
	    03 waa-d-notion-flag		pic 9.
	    03 waa-p-notion-flag		pic 9.
	    03 waa-emp-change			pic 9.
	    03 waa-dept-print			pic 9.
	    03 waa-sub-print			pic 9.
	    03 waa-fmt-flag			pic 9.
	    03 waa-prt-eof			pic 9.
	    03 waa-print-flag			pic 9.
	    03 waa-eof-flag			pic 9.
	    03 waa-new-rec-mkr			pic 9.
	    03 waa-coinage-mkr			pic 9.
	    03 waa-use-nicalc5-mkr		pic 9.

      ******************************************************************
      //////////////////////////////////////////////////////////////////

	01 wab-date.
	    03 wab-cc				pic 9(2).
	    03 wab-yy				pic 9(2).
	    03 wab-mm				pic 9(2).
	    03 wab-dd				pic 9(2).

	01 wab-tax-date.
	    03 filler				pic xx.
	    03 wab-tax-cut-date.
		05 wab-tax-cut-date-yy		pic x(2).
		05 filler			pic x(4).

	01 wab-ord-str.
	    03 filler				pic x(40) value
		"*D====*C==========*E======*S====".

	01 wab-months-fill			pic x(36) value
		"JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC".

	01 wab-months redefines wab-months-fill.
	    03 wab-mon occurs 12.
		05 wab-month-str		pic xxx.

	01 wab-subscripts.
	    03 wab-methods.
		05 wab-net-paid			pic 9(5).
		05 wab-male-cnt			pic 9(5).
		05 wab-female-cnt		pic 9(5).
		05 wab-male-paid		pic 9(5).
		05 wab-female-paid		pic 9(5).
		05 wab-male-not-paid		pic 9(5).
		05 wab-female-not-paid		pic 9(5).
		05 wab-male-left-cnt		pic 9(5).
		05 wab-female-left-cnt		pic 9(5).
		05 wab-cash-cnt			pic 9(5).
		05 wab-other-cnt		pic 9(5).
		05 wab-bank-cnt			pic 9(5).
		05 wab-cash-amt			pic s9(12).
		05 wab-other-amt		pic s9(12).
		05 wab-bank-amt			pic s9(12).
		05 wab-male-total		pic s9(12).
		05 wab-female-total		pic s9(12).
	    03 wab-dept-methods.
		05 wab-d-net-paid		pic 9(5).
		05 wab-d-male-cnt		pic 9(5).
		05 wab-d-female-cnt		pic 9(5).
		05 wab-d-male-paid		pic 9(5).
		05 wab-d-female-paid		pic 9(5).
		05 wab-d-male-not-paid		pic 9(5).
		05 wab-d-female-not-paid	pic 9(5).
		05 wab-d-male-left-cnt		pic 9(5).
		05 wab-d-female-left-cnt	pic 9(5).
		05 wab-d-cash-cnt		pic 9(5).
		05 wab-d-other-cnt		pic 9(5).
		05 wab-d-bank-cnt		pic 9(5).
		05 wab-d-cash-amt		pic s9(12).
		05 wab-d-other-amt		pic s9(12).
		05 wab-d-bank-amt		pic s9(12).
		05 wab-d-male-total		pic s9(12).
		05 wab-d-female-total		pic s9(12).
	    03 wab-payroll-methods.
		05 wab-p-net-paid		pic 9(5).
		05 wab-p-male-not-paid		pic 9(5).
		05 wab-p-female-not-paid	pic 9(5).
		05 wab-p-male-paid		pic 9(5).
		05 wab-p-female-paid		pic 9(5).
		05 wab-p-cash-cnt		pic 9(5).
		05 wab-p-other-cnt		pic 9(5).
		05 wab-p-bank-cnt		pic 9(5).
		05 wab-p-cash-amt		pic s9(12).
		05 wab-p-other-amt		pic s9(12).
		05 wab-p-bank-amt		pic s9(12).
	    03 wab-gen-cnt			pic 9(2).
	    03 wab-ni-cnt			pic 9(2).
	    03 wab-summ-lines			pic 9(3).
	    03 wab-page-cnt			pic 9(3).
	    03 wab-read-mkr			pic 9.
	    03 wab-maths-cnt			pic 9(2).
	    03 wab-emp-cnt			pic 9(4).
	    03 wab-d-emp-cnt			pic 9(4).
	    03 wab-p-emp-cnt			pic 9(4).
	    03 wab-line-cnt			pic 9(3).
	    03 wab-test-cnt			pic 9(3).
	    03 wab-page-len			pic 9(3).
	    03 wab-margin			pic s9(3).
	    03 wab-spacing			pic s9(3).
	    03 wab-throw-mkr			pic 9.
	    03 wab-code-type			pic 9.
	    03 wab-page-div			pic 9(2).
	    03 wab-page-rem			pic 9.
	    03 wab-code-save			pic 9(4).
	    03 wab-cnt				pic s9(4).

      ******************************************************************
      //////////////////////////////////////////////////////////////////

	01 wac-intention-str.
	    03 filler				pic x(40).
	    03 filler				pic x(60) value
		"THIS PAGE LEFT BLANK INTENTIONALLY.".

	01 wac-csh-totals.
	    03 wac-cash-vars.
		05 wac-csh-cnts			pic 9(5) occurs 11.
	    03 wac-d-cash-vars.
		05 wac-d-csh-var		pic 9(5) occurs 11.
	    03 wac-p-cash-vars.
		05 wac-p-csh-var		pic 9(5) occurs 11.

	01 wac-print-headers.
	    03 wac-hd-line3.
		05 wac-user-name		pic x(40).
		05 filler			pic x.
		05 wac-user-no			pic x(6).
		05 wac-dept-str			pic x(5).
		05 wac-dept-no.
		   07 wac-dept-noz		pic z(5)9.
		05 filler			pic x.
		05 wac-sub-string.
		    07 wac-sub-str		pic x(9) value
			"SUB-DEPT ".
		    07 wac-sub-dept.
			09 wac-sub-deptz	pic z(5)9.
			09 filler		pic x(6).
		05 filler			pic x(29) value
			" PAYROLL SUMMARY  TAX PERIOD ".
		05 wac-tax-period		pic xx.
		05 filler			pic x(4).
		05 wac-prt-date.	
		    07 wac-prt-dd		pic xx.
		    07 wac-prt-mon		pic xxx.
	 	    07 wac-prt-yy		pic xx.
		05 filler			pic x(7) value
			"  PAGE ".
		05 wac-page-no			pic z(2)9.
	    03 wac-hd-line4.
		05 filler			pic x(36).
		05 filler			pic x(52) value
			"B/FWD           MANUALS       ADJUSTMENTS".
		05 filler			pic x(44) value
			"CURRENT    MANUAL+CURRENT             C/FWD".
	    03 wac-ft-line1.
		05 filler			pic x(27) value
			"PAY METHODS COUNTS:  CASH".
		05 wac-cash-cnt			pic z(4)9.
		05 filler			pic x.
		05 wac-cash-amt			pic z(9)9.99-.
		05 filler			pic x(36).
		05 filler			pic x(48) value
		" EMPLOYEE COUNTS:   PAID  NO PAY    LEFT   TOTAL".
	    03 wac-ft-line2.
		05 filler			pic x(19).
		05 filler			pic x(8) value
			" OTHER".
		05 wac-other-cnt		pic z(4)9.
		05 filler			pic x.
		05 wac-other-amt		pic z(9)9.99.
		05 filler			pic x(49).
		05 filler			pic x(7) value
			" MALE".
		05 wac-male-paid		pic z(4)9.
		05 filler			pic xxx.
		05 wac-male-no-pay		pic z(4)9.
		05 filler			pic xxx.
		05 wac-male-left		pic z(4)9.
		05 filler			pic xxx.
		05 wac-male-total		pic z(4)9.
	    03 wac-ft-line3.
		05 filler			pic x(20).
		05 filler			pic x(7) value
			" BANK".
		05 wac-bank-cnt			pic z(4)9.
		05 filler			pic x.
		05 wac-bank-amt			pic z(9)9.99-.
		05 filler			pic x(47).
		05 filler			pic x(8) value
			"FEMALE".
		05 wac-female-paid		pic z(4)9.
		05 filler			pic xxx.
		05 wac-female-no-pay		pic z(4)9.
		05 filler			pic xxx.
		05 wac-female-left		pic z(4)9.
		05 filler			pic xxx.
		05 wac-female-total		pic z(4)9.
	    03 wac-ft-line4.
		05 filler			pic x(102).
		05 wac-paid-total		pic z(4)9.
		05 filler			pic xxx.
		05 wac-no-pay-total		pic z(4)9.
		05 filler			pic xxx.
		05 wac-left-total		pic z(4)9.
		05 filler			pic xxx.
		05 wac-overall-total		pic z(4)9.
	    03 wac-ft-line5.
		05 filler			pic x(20) value
			"CASH ANALYSIS    #50".
		05 filler			pic x(10) value
			"       #20".
		05 filler			pic x(10) value
			"       #10".
		05 filler			pic x(10) value
			"        #5".
		05 filler			pic x(10) value
			"        #1".
		05 filler			pic x(10) value
			"       50p".
		05 filler			pic x(10) value
			"       20p".
		05 filler			pic x(10) value
			"       10p".
		05 filler			pic x(10) value
			"        5p".
		05 filler			pic x(10) value
			"        2p".
		05 filler			pic x(10) value
			"        1p".
		05 filler			pic x(10) value
			"     TOTAL".
	    03 wac-ft-line6.
		05 filler			pic x(15) value
			"   NO.".
		05 wac-csh-cnt.
		    07 wac-csh-vars	occurs 11.
			09 wac-cash-cnts	pic z(4)9.
			09 filler		pic x(5).
	    03 wac-ft-line7.
		05 filler			pic x(12) value
			"   VALUE".
		05 wac-amounts.
		    07 wac-amount-vars	occurs 12.
			09 wac-csh-amt		pic z(4)9.99.
			09 filler		pic xx.
	    03 wac-ft-line8.
		05 filler			pic x(26) value
			"DSS DETAILS:   PERMIT NO: ".
		05 wac-permit-ftl8		pic x(12).
		05 filler			pic x(4) value spaces.
		05 filler			pic x(14) value
			"TAX DISTRICT: ".
		05 wac-tax-dist-ftl8		pic x(3).
		05 filler			pic x(4) value spaces.
		05 filler			pic x(15) value
			"TAX REFERENCE: ".
		05 wac-tax-ref-ftl8		pic x(7).

      ******************************************************************
      //////////////////////////////////////////////////////////////////

	01 wad-pay-mth-str.
	    03 wad-paym-str1			pic x(40) value
		"PAY METHODS FOLLOW ON NEXT PAGE".
	    03 wad-paym-str2			pic x(70) value
		"PAY METHODS AND CASH ANALYSIS FOLLOW ON NEXT PAGE".

	copy "p32form".
        
	01 wad-summ-notes-1.
	    03 filler			pic x(49) value
		"The above figures do not include any calculation ".
	    03 filler			pic x(48) value
		"from entries in the Payroll Summary Adjustments ".
	    03 filler			pic x(35) value
		"columns.".

	01 wad-summ-notes-2.
	    03 filler			pic x(50) value
		"Any additional payments or reductions due must be ".
	    03 filler			pic x(50) value
		"made manually.".
	    03 filler			pic x(32) value spaces.

	01 wad-ssp-notes-1.
	    03 filler			pic x(52) value
		"SSP Paid exceeds 13% of total Gross NIC. A total of ".
	    03 wad-ssp-notes1-val	pic #(4)9.99-.
	    03 filler			pic x(50) value
		" has been recovered from the Tax reference above.".

	01 wad-ssp-notes-2.
	    03 filler			pic x(49) value
		"If the Employer is responsible for the Gross NIC ".
	    03 filler			pic x(50) value
		"not shown on this payroll the SSP recovery figure ".
	    03 filler			pic x(33) value
		"shown will not be correct.".

	01 wad-save-values.
	    03 wad-save-cost			pic x(12).
	    03 wad-work-cost			pic x(12).
	    03 wad-split-cost.
		05 wad-cost-dept		pic x(6).
		05 wad-cost-str			pic x(12).
		05 filler			pic x(22).
	    03 wad-save-pay-type		pic x.
	    03 wad-save-all-key.
		05 wad-save-dept		pic x(6).
		05 wad-save-sub-long.
		    07 wad-save-sub		pic x(6).
		    07 filler			pic x(6).
		05 wad-save-emp			pic x(8).
	    03 wad-gen-amt			pic s9(12).
	    03 wad-shuffle-code.
		05 wad-code			pic xxx.
		05 wad-code-n			pic x.
	    03 wad-summ-amt			pic s9(12).
	    03 wad-summ-cnt			pic s9(2).
	    03 wad-fbb-key.
		05 wad-fbb-dept			pic x(6).
		05 wad-fbb-sub-dept		pic x(6).
		05 filler			pic x(8).

	01 wad-split-fja-key.
	    03 wad-fja-dept			pic x(6).
	    03 wad-fja-sub-dept			pic x(6).
	    03 wad-fja-emp			pic x(8).

	01 wad-save-last-key.
	    03 wad-last-dept			pic x(6).
	    03 wad-last-sub-dept		pic x(6).
	    03 wad-last-emp			pic x(8).

	01 wad-save-new-key.
	    03 filler				pic x(6).
	    03 wad-sub-dept-new			pic x(6).
	    03 filler				pic x(8).

	01 wad-norm-code.
	    03 wad-norm-n			pic x.
	    03 wad-norm-data			pic xxx.

       01  wad-misc.
           03  wad-ni-nar1          pic x(4) value "TOET".

      ******************************************************************
      //////////////////////////////////////////////////////////////////

	01 wae-totalling.
	    03 wae-3rd-not-inc-totes.
		05 wae-3rd-not-inc.
		    07 wae-3rd-no-inc		pic s9(12) occurs 6.
		05 wae-d-3rd-not-inc.
		    07 wae-d-3rd-no-inc		pic s9(12) occurs 6.
		05 wae-p-3rd-not-inc.
		    07 wae-p-3rd-no-inc		pic s9(12) occurs 6.
	    03 wae-sub-group-totals.
		05 wae-n81-n123-tots.
		    07 wae-n81-n123-tote	pic s9(12) occurs 6.
		05 wae-d-n81-n123-tots.
		    07 wae-d-n81-n123-tote	pic s9(12) occurs 6.
		05 wae-p-n81-n123-tots.
		    07 wae-p-n81-n123-tote	pic s9(12) occurs 6.
		05 wae-n125-n167-tots.
		    07 wae-n125-n167-tote	pic s9(12) occurs 6.
		05 wae-d-n125-n167-tots.
		    07 wae-d-n125-n167-tote	pic s9(12) occurs 6.
		05 wae-p-n125-n167-tots.
		    07 wae-p-n125-n167-tote	pic s9(12) occurs 6.
		05 wae-n169-n211-tots.
		    07 wae-n169-n211-tote	pic s9(12) occurs 6.
		05 wae-d-n169-n211-tots.
		    07 wae-d-n169-n211-tote	pic s9(12) occurs 6.
		05 wae-p-n169-n211-tots.
		    07 wae-p-n169-n211-tote	pic s9(12) occurs 6.
		05 wae-n325-n363-tots.
		    07 wae-n325-n363-tote	pic s9(12) occurs 6.
		05 wae-d-n325-n363-tots.
		    07 wae-d-n325-n363-tote	pic s9(12) occurs 6.
		05 wae-p-n325-n363-tots.
		    07 wae-p-n325-n363-tote	pic s9(12) occurs 6.
		05 wae-n431-n519-tots.
		    07 wae-n431-n519-tote	pic s9(12) occurs 6.
		05 wae-d-n431-n519-tots.
		    07 wae-d-n431-n519-tote	pic s9(12) occurs 6.
		05 wae-p-n431-n519-tots.
		    07 wae-p-n431-n519-tote	pic s9(12) occurs 6.
		05 wae-n521-n533-tots.
		    07 wae-n521-n533-tote	pic s9(12) occurs 6.
		05 wae-d-n521-n533-tots.
		    07 wae-d-n521-n533-tote	pic s9(12) occurs 6.
		05 wae-p-n521-n533-tots.
		    07 wae-p-n521-n533-tote	pic s9(12) occurs 6.
	    03 wae-save-3rd-totals.
		05 wae-save-3rd-tot		pic s9(12) occurs 6.
	    03 wae-result			pic s9(12).
	    03 wae-ave-totals.
		05 wae-ave-pay			pic s9(12) occurs 6.
	    03 wae-gross-totals.
		05 wae-gross-pay		pic s9(12) occurs 6.
	    03 wae-d-gross-totals.
		05 wae-d-gross-pay		pic s9(12) occurs 6.
	    03 wae-p-gross-totals.
		05 wae-p-gross-pay		pic s9(12) occurs 6.
	    03 wae-mits-net.
		05 wae-mits-net-pay		pic s9(12) occurs 6.
	    03 wae-d-mits-net.
		05 wae-d-mits-net-pay		pic s9(12) occurs 6.
	    03 wae-p-mits-net.
		05 wae-p-mits-net-pay		pic s9(12) occurs 6.
	    03 wae-ssp-totals.
		05 wae-ssp-pay			pic s9(12) occurs 6.
	    03 wae-d-ssp-totals.
		05 wae-d-ssp-pay		pic s9(12) occurs 6.
	    03 wae-p-ssp-totals.
		05 wae-p-ssp-pay		pic s9(12) occurs 6.
	    03 wae-smpi-totals.
		05 wae-smpi-pay			pic s9(12) occurs 6.
	    03 wae-d-smpi-totals.
		05 wae-d-smpi-pay		pic s9(12) occurs 6.
	    03 wae-p-smpi-totals.
		05 wae-p-smpi-pay		pic s9(12) occurs 6.
	    03 wae-sapi-totals.
		05 wae-sapi-pay			pic s9(12) occurs 6.
	    03 wae-d-sapi-totals.
		05 wae-d-sapi-pay		pic s9(12) occurs 6.
	    03 wae-p-sapi-totals.
		05 wae-p-sapi-pay		pic s9(12) occurs 6.
	    03 wae-sppi-totals.
		05 wae-sppi-pay			pic s9(12) occurs 6.
	    03 wae-d-sppi-totals.
		05 wae-d-sppi-pay		pic s9(12) occurs 6.
	    03 wae-p-sppi-totals.
		05 wae-p-sppi-pay		pic s9(12) occurs 6.
	    03 wae-asppi-totals.
		05 wae-asppi-pay		pic s9(12) occurs 6.
	    03 wae-d-asppi-totals.
		05 wae-d-asppi-pay		pic s9(12) occurs 6.
	    03 wae-p-asppi-totals.
		05 wae-p-asppi-pay		pic s9(12) occurs 6.
	    03 wae-smp-totals.
		05 wae-smp-pay			pic s9(12) occurs 6.
	    03 wae-d-smp-totals.
		05 wae-d-smp-pay		pic s9(12) occurs 6.
	    03 wae-p-smp-totals.
		05 wae-p-smp-pay		pic s9(12) occurs 6.
	    03 wae-sap-totals.
		05 wae-sap-pay			pic s9(12) occurs 6.
	    03 wae-d-sap-totals.
		05 wae-d-sap-pay		pic s9(12) occurs 6.
	    03 wae-p-sap-totals.
		05 wae-p-sap-pay		pic s9(12) occurs 6.
	    03 wae-spp-totals.
		05 wae-spp-pay			pic s9(12) occurs 6.
	    03 wae-d-spp-totals.
		05 wae-d-spp-pay		pic s9(12) occurs 6.
	    03 wae-p-spp-totals.
		05 wae-p-spp-pay		pic s9(12) occurs 6.
	    03 wae-aspp-totals.
		05 wae-aspp-pay			pic s9(12) occurs 6.
	    03 wae-d-aspp-totals.
		05 wae-d-aspp-pay		pic s9(12) occurs 6.
	    03 wae-p-aspp-totals.
		05 wae-p-aspp-pay		pic s9(12) occurs 6.
	    03 wae-ded-totals.
		05 wae-total-ded		pic s9(12) occurs 6.
	    03 wae-d-ded-totals.
		05 wae-d-total-ded		pic s9(12) occurs 6.
	    03 wae-p-ded-totals.
		05 wae-p-total-ded		pic s9(12) occurs 6.
	    03 wae-debt-totals.
		05 wae-debt-tot			pic s9(12) occurs 6.
	    03 wae-d-debt-totals.
		05 wae-d-debt-tot		pic s9(12) occurs 6.
	    03 wae-p-debt-totals.
		05 wae-p-debt-tot		pic s9(12) occurs 6.
	    03 wae-round-totals.
		05 wae-round-tot		pic s9(12) occurs 6.
	    03 wae-d-round-totals.
		05 wae-d-round-tot		pic s9(12) occurs 6.
	    03 wae-p-round-totals.
		05 wae-p-round-tot		pic s9(12) occurs 6.
	    03 wae-comc1-totals.
		05 wae-comc1-tot		pic s9(12) occurs 6.
	    03 wae-d-comc1-totals.
		05 wae-d-comc1-tot		pic s9(12) occurs 6.
	    03 wae-p-comc1-totals.
		05 wae-p-comc1-tot		pic s9(12) occurs 6.
	    03 wae-comc1A-totals.
		05 wae-comc1A-tot		pic s9(12) occurs 6.
	    03 wae-d-comc1A-totals.
		05 wae-d-comc1A-tot		pic s9(12) occurs 6.
	    03 wae-p-comc1A-totals.
		05 wae-p-comc1A-tot		pic s9(12) occurs 6.
	    03 wae-comc2-totals.
		05 wae-comc2-tot		pic s9(12) occurs 6.
	    03 wae-d-comc2-totals.
		05 wae-d-comc2-tot		pic s9(12) occurs 6.
	    03 wae-p-comc2-totals.
		05 wae-p-comc2-tot		pic s9(12) occurs 6.
	    03 wae-comc2A-totals.
		05 wae-comc2A-tot		pic s9(12) occurs 6.
	    03 wae-d-comc2A-totals.
		05 wae-d-comc2A-tot		pic s9(12) occurs 6.
	    03 wae-p-comc2A-totals.
		05 wae-p-comc2A-tot		pic s9(12) occurs 6.
	    03 wae-comc3-totals.
		05 wae-comc3-tot		pic s9(12) occurs 6.
	    03 wae-d-comc3-totals.
		05 wae-d-comc3-tot		pic s9(12) occurs 6.
	    03 wae-p-comc3-totals.
		05 wae-p-comc3-tot		pic s9(12) occurs 6.
	    03 wae-comc3A-totals.
		05 wae-comc3A-tot		pic s9(12) occurs 6.
	    03 wae-d-comc3A-totals.
		05 wae-d-comc3A-tot		pic s9(12) occurs 6.
	    03 wae-p-comc3A-totals.
		05 wae-p-comc3A-tot		pic s9(12) occurs 6.
	    03 wae-cod1-totals.
		05 wae-cod1-tot			pic s9(12) occurs 6.
	    03 wae-d-cod1-totals.
		05 wae-d-cod1-tot		pic s9(12) occurs 6.
	    03 wae-p-cod1-totals.
		05 wae-p-cod1-tot		pic s9(12) occurs 6.
	    03 wae-cod1A-totals.
		05 wae-cod1A-tot		pic s9(12) occurs 6.
	    03 wae-d-cod1A-totals.
		05 wae-d-cod1A-tot		pic s9(12) occurs 6.
	    03 wae-p-cod1A-totals.
		05 wae-p-cod1A-tot		pic s9(12) occurs 6.
	    03 wae-cod2-totals.
		05 wae-cod2-tot			pic s9(12) occurs 6.
	    03 wae-d-cod2-totals.
		05 wae-d-cod2-tot		pic s9(12) occurs 6.
	    03 wae-p-cod2-totals.
		05 wae-p-cod2-tot		pic s9(12) occurs 6.
	    03 wae-cod2A-totals.
		05 wae-cod2A-tot		pic s9(12) occurs 6.
	    03 wae-d-cod2A-totals.
		05 wae-d-cod2A-tot		pic s9(12) occurs 6.
	    03 wae-p-cod2A-totals.
		05 wae-p-cod2A-tot		pic s9(12) occurs 6.
	    03 wae-cod3-totals.
		05 wae-cod3-tot			pic s9(12) occurs 6.
	    03 wae-d-cod3-totals.
		05 wae-d-cod3-tot		pic s9(12) occurs 6.
	    03 wae-p-cod3-totals.
		05 wae-p-cod3-tot		pic s9(12) occurs 6.
	    03 wae-cod3A-totals.
		05 wae-cod3A-tot		pic s9(12) occurs 6.
	    03 wae-d-cod3A-totals.
		05 wae-d-cod3A-tot		pic s9(12) occurs 6.
	    03 wae-p-cod3A-totals.
		05 wae-p-cod3A-tot		pic s9(12) occurs 6.
	    03 wae-cod4-totals.
		05 wae-cod4-tot			pic s9(12) occurs 6.
	    03 wae-d-cod4-totals.
		05 wae-d-cod4-tot		pic s9(12) occurs 6.
	    03 wae-p-cod4-totals.
		05 wae-p-cod4-tot		pic s9(12) occurs 6.
	    03 wae-cod4A-totals.
		05 wae-cod4A-tot		pic s9(12) occurs 6.
	    03 wae-d-cod4A-totals.
		05 wae-d-cod4A-tot		pic s9(12) occurs 6.
	    03 wae-p-cod4A-totals.
		05 wae-p-cod4A-tot		pic s9(12) occurs 6.
	    03 wae-pri1-totals.
		05 wae-pri1-tot			pic s9(12) occurs 6.
	    03 wae-d-pri1-totals.
		05 wae-d-pri1-tot		pic s9(12) occurs 6.
	    03 wae-p-pri1-totals.
		05 wae-p-pri1-tot		pic s9(12) occurs 6.
	    03 wae-aeos-totals.
		05 wae-aeos-tot			pic s9(12) occurs 6.
	    03 wae-d-aeos-totals.
		05 wae-d-aeos-tot		pic s9(12) occurs 6.
	    03 wae-p-aeos-totals.
		05 wae-p-aeos-tot		pic s9(12) occurs 6.
	    03 wae-sl-totals.
		05 wae-sl-tot			pic s9(12) occurs 6.
	    03 wae-d-sl-totals.
		05 wae-d-sl-tot			pic s9(12) occurs 6.
	    03 wae-p-sl-totals.
		05 wae-p-sl-tot			pic s9(12) occurs 6.
	    03 wae-eesni-totals.
		05 wae-eesni-tot		pic s9(12) occurs 6.
	    03 wae-d-eesni-totals.
		05 wae-d-eesni-tot		pic s9(12) occurs 6.
	    03 wae-p-eesni-totals.
		05 wae-p-eesni-tot		pic s9(12) occurs 6.
	    03 wae-ersni-totals.
		05 wae-ersni-tot		pic s9(12) occurs 6.
	    03 wae-d-ersni-totals.
		05 wae-d-ersni-tot		pic s9(12) occurs 6.
	    03 wae-p-ersni-totals.
		05 wae-p-ersni-tot		pic s9(12) occurs 6.
	    03 wae-non-tax-totals.
		05 wae-non-tax-tot		pic s9(12) occurs 6.
	    03 wae-d-non-tax-totals.
		05 wae-d-non-tax-tot		pic s9(12) occurs 6.
	    03 wae-p-non-tax-totals.
		05 wae-p-non-tax-tot		pic s9(12) occurs 6.
	    03 wae-ftc-totals.
		05 wae-ftc-pay			pic s9(12) occurs 6.
	    03 wae-d-ftc-totals.
		05 wae-d-ftc-pay		pic s9(12) occurs 6.
	    03 wae-p-ftc-totals.
		05 wae-p-ftc-pay		pic s9(12) occurs 6.
	    03 wae-3rd-totals.
		05 wae-3rd-tot			pic s9(12) occurs 6.
	    03 wae-d-3rd-totals.
		05 wae-d-3rd-tot		pic s9(12) occurs 6.
	    03 wae-p-3rd-totals.
		05 wae-p-3rd-tot		pic s9(12) occurs 6.
	    03 wae-notion-ssp-totals.
		05 wae-notion-ssp-tot		pic s9(12) occurs 6.
	    03 wae-d-notion-ssp-totals.
		05 wae-d-notion-ssp-tot		pic s9(12) occurs 6.
	    03 wae-p-notion-ssp-totals.
		05 wae-p-notion-ssp-tot		pic s9(12) occurs 6.
	    03 wae-notion-smp-totals.
		05 wae-notion-smp-tot		pic s9(12) occurs 6.
	    03 wae-d-notion-smp-totals.
		05 wae-d-notion-smp-tot		pic s9(12) occurs 6.
	    03 wae-p-notion-smp-totals.
		05 wae-p-notion-smp-tot		pic s9(12) occurs 6.
	    03 wae-notion-sap-totals.
		05 wae-notion-sap-tot		pic s9(12) occurs 6.
	    03 wae-d-notion-sap-totals.
		05 wae-d-notion-sap-tot		pic s9(12) occurs 6.
	    03 wae-p-notion-sap-totals.
		05 wae-p-notion-sap-tot		pic s9(12) occurs 6.
	    03 wae-notion-spp-totals.
		05 wae-notion-spp-tot		pic s9(12) occurs 6.
	    03 wae-d-notion-spp-totals.
		05 wae-d-notion-spp-tot		pic s9(12) occurs 6.
	    03 wae-p-notion-spp-totals.
		05 wae-p-notion-spp-tot		pic s9(12) occurs 6.
	    03 wae-notion-aspp-totals.
		05 wae-notion-aspp-tot		pic s9(12) occurs 6.
	    03 wae-d-notion-aspp-totals.
		05 wae-d-notion-aspp-tot	pic s9(12) occurs 6.
	    03 wae-p-notion-aspp-totals.
		05 wae-p-notion-aspp-tot	pic s9(12) occurs 6.
	    03 wae-dss-totals.
		05 wae-dss-tote.
		    07 wae-dss-tote-pay		pic s9(12) occurs 6.
		05 wae-dss-smp-totals.
		    07 wae-dss-smp-pay		pic s9(12) occurs 6.
		05 wae-ssp-rec-totals.
		    07 wae-ssp-rec-pay		pic s9(12) occurs 6.
		05 wae-smp-com-totals.
		    07 wae-smp-com-pay		pic s9(12) occurs 6.
		05 wae-sap-com-totals.
		    07 wae-sap-com-pay		pic s9(12) occurs 6.
		05 wae-spp-com-totals.
		    07 wae-spp-com-pay		pic s9(12) occurs 6.
		05 wae-aspp-com-totals.
		    07 wae-aspp-com-pay		pic s9(12) occurs 6.
		05 wae-smp-rec-totals.
		    07 wae-smp-rec-pay		pic s9(12) occurs 6.
		05 wae-sap-rec-totals.
		    07 wae-sap-rec-pay		pic s9(12) occurs 6.
		05 wae-spp-rec-totals.
		    07 wae-spp-rec-pay		pic s9(12) occurs 6.
		05 wae-aspp-rec-totals.
		    07 wae-aspp-rec-pay		pic s9(12) occurs 6.
	    03 wae-dss-dept-totals.
		05 wae-d-dss-tote.
		    07 wae-d-dss-tote-pay	pic s9(12) occurs 6.
		05 wae-d-dss-smp-totals.
		    07 wae-d-dss-smp-pay	pic s9(12) occurs 6.
		05 wae-d-ssp-rec-totals.
		    07 wae-d-ssp-rec-pay	pic s9(12) occurs 6.
		05 wae-d-smp-com-totals.
		    07 wae-d-smp-com-pay	pic s9(12) occurs 6.
		05 wae-d-sap-com-totals.
		    07 wae-d-sap-com-pay	pic s9(12) occurs 6.
		05 wae-d-spp-com-totals.
		    07 wae-d-spp-com-pay	pic s9(12) occurs 6.
		05 wae-d-aspp-com-totals.
		    07 wae-d-aspp-com-pay	pic s9(12) occurs 6.
		05 wae-d-smp-rec-totals.
		    07 wae-d-smp-rec-pay	pic s9(12) occurs 6.
		05 wae-d-sap-rec-totals.
		    07 wae-d-sap-rec-pay	pic s9(12) occurs 6.
		05 wae-d-spp-rec-totals.
		    07 wae-d-spp-rec-pay	pic s9(12) occurs 6.
		05 wae-d-aspp-rec-totals.
		    07 wae-d-aspp-rec-pay	pic s9(12) occurs 6.
	    03 wae-dss-pay-totals.
		05 wae-p-dss-tote.
		    07 wae-p-dss-tote-pay	pic s9(12) occurs 6.
		05 wae-p-dss-smp-totals.
		    07 wae-p-dss-smp-pay	pic s9(12) occurs 6.
		05 wae-p-ssp-rec-totals.
		    07 wae-p-ssp-rec-pay	pic s9(12) occurs 6.
		05 wae-p-smp-com-totals.
		    07 wae-p-smp-com-pay	pic s9(12) occurs 6.
		05 wae-p-sap-com-totals.
		    07 wae-p-sap-com-pay	pic s9(12) occurs 6.
		05 wae-p-spp-com-totals.
		    07 wae-p-spp-com-pay	pic s9(12) occurs 6.
		05 wae-p-aspp-com-totals.
		    07 wae-p-aspp-com-pay	pic s9(12) occurs 6.
		05 wae-p-smp-rec-totals.
		    07 wae-p-smp-rec-pay	pic s9(12) occurs 6.
		05 wae-p-sap-rec-totals.
		    07 wae-p-sap-rec-pay	pic s9(12) occurs 6.
		05 wae-p-spp-rec-totals.
		    07 wae-p-spp-rec-pay	pic s9(12) occurs 6.
		05 wae-p-aspp-rec-totals.
		    07 wae-p-aspp-rec-pay	pic s9(12) occurs 6.
	    03 wae-taxed-totals.
		05 wae-tax-taxable.
		    07 wae-taxable-tot		pic s9(12) occurs 6.
		05 wae-tax-tax.
		    07 wae-tax-tot		pic s9(12) occurs 6.
		05 wae-p45-tax.
		    07 wae-p45-tot		pic s9(12) occurs 6.
		05 wae-p45-taxable.
		    07 wae-p45-taxable-tot	pic s9(12) occurs 6.
	    03 wae-taxed-dept-totals.
		05 wae-d-tax-taxable.
		    07 wae-d-taxable-tot	pic s9(12) occurs 6.
		05 wae-d-tax-tax.
		    07 wae-d-tax-tot		pic s9(12) occurs 6.
		05 wae-d-p45-tax.
		    07 wae-d-p45-tot		pic s9(12) occurs 6.
		05 wae-d-p45-taxable.
		    07 wae-d-p45-taxable-tot	pic s9(12) occurs 6.
	    03 wae-taxed-payroll-totals.
		05 wae-p-tax-taxable.
		    07 wae-p-taxable-tot	pic s9(12) occurs 6.
		05 wae-p-tax-tax.
		    07 wae-p-tax-tot		pic s9(12) occurs 6.
		05 wae-p-p45-taxable.
		    07 wae-p-p45-taxable-tot	pic s9(12) occurs 6.
		05 wae-p-p45-tax.
		    07 wae-p-p45-tot		pic s9(12) occurs 6.
	    03 wae-niables-totals.
		05 wae-nitot-totals.
		    07 wae-nitot-pay		pic s9(12) occurs 6.
		05 wae-niable-a-totals.
		    07 wae-niable-a-tot		pic s9(12) occurs 6.
		05 wae-tolel-a-totals.
		    07 wae-tolel-a-tot		pic s9(12) occurs 6.
		05 wae-toet-a-totals.
		    07 wae-toet-a-tot		pic s9(12) occurs 6.
		05 wae-touap-a-totals.
		    07 wae-touap-a-tot		pic s9(12) occurs 6.
		05 wae-touel-a-totals.
		    07 wae-touel-a-tot		pic s9(12) occurs 6.
		05 wae-uelplus-a-totals.
		    07 wae-uelplus-a-tot	pic s9(12) occurs 6.
		05 wae-niable-b-totals.
		    07 wae-niable-b-tot		pic s9(12) occurs 6.
		05 wae-tolel-b-totals.
		    07 wae-tolel-b-tot		pic s9(12) occurs 6.
		05 wae-toet-b-totals.
		    07 wae-toet-b-tot		pic s9(12) occurs 6.
		05 wae-touap-b-totals.
		    07 wae-touap-b-tot		pic s9(12) occurs 6.
		05 wae-touel-b-totals.
		    07 wae-touel-b-tot		pic s9(12) occurs 6.
		05 wae-uelplus-b-totals.
		    07 wae-uelplus-b-tot	pic s9(12) occurs 6.
		05 wae-niable-c-totals.
		    07 wae-niable-c-tot		pic s9(12) occurs 6.
		05 wae-tolel-c-totals.
		    07 wae-tolel-c-tot		pic s9(12) occurs 6.
		05 wae-toet-c-totals.
		    07 wae-toet-c-tot		pic s9(12) occurs 6.
		05 wae-touap-c-totals.
		    07 wae-touap-c-tot		pic s9(12) occurs 6.
		05 wae-touel-c-totals.
		    07 wae-touel-c-tot		pic s9(12) occurs 6.
		05 wae-uelplus-c-totals.
		    07 wae-uelplus-c-tot	pic s9(12) occurs 6.
		05 wae-niable-d-totals.
		    07 wae-niable-d-tot		pic s9(12) occurs 6.
		05 wae-tolel-d-totals.
		    07 wae-tolel-d-tot		pic s9(12) occurs 6.
		05 wae-toet-d-totals.
		    07 wae-toet-d-tot		pic s9(12) occurs 6.
		05 wae-touap-d-totals.
		    07 wae-touap-d-tot		pic s9(12) occurs 6.
		05 wae-touel-d-totals.
		    07 wae-touel-d-tot		pic s9(12) occurs 6.
		05 wae-uelplus-d-totals.
		    07 wae-uelplus-d-tot	pic s9(12) occurs 6.
		05 wae-niable-e-totals.
		    07 wae-niable-e-tot		pic s9(12) occurs 6.
		05 wae-tolel-e-totals.
		    07 wae-tolel-e-tot		pic s9(12) occurs 6.
		05 wae-toet-e-totals.
		    07 wae-toet-e-tot		pic s9(12) occurs 6.
		05 wae-touap-e-totals.
		    07 wae-touap-e-tot		pic s9(12) occurs 6.
		05 wae-touel-e-totals.
		    07 wae-touel-e-tot		pic s9(12) occurs 6.
		05 wae-uelplus-e-totals.
		    07 wae-uelplus-e-tot	pic s9(12) occurs 6.
		05 wae-niable-f-totals.
		    07 wae-niable-f-tot		pic s9(12) occurs 6.
		05 wae-tolel-f-totals.
		    07 wae-tolel-f-tot		pic s9(12) occurs 6.
		05 wae-toet-f-totals.
		    07 wae-toet-f-tot		pic s9(12) occurs 6.
		05 wae-touap-f-totals.
		    07 wae-touap-f-tot		pic s9(12) occurs 6.
		05 wae-touel-f-totals.
		    07 wae-touel-f-tot		pic s9(12) occurs 6.
		05 wae-uelplus-f-totals.
		    07 wae-uelplus-f-tot	pic s9(12) occurs 6.
		05 wae-niable-g-totals.
		    07 wae-niable-g-tot		pic s9(12) occurs 6.
		05 wae-tolel-g-totals.
		    07 wae-tolel-g-tot		pic s9(12) occurs 6.
		05 wae-toet-g-totals.
		    07 wae-toet-g-tot		pic s9(12) occurs 6.
		05 wae-touap-g-totals.
		    07 wae-touap-g-tot		pic s9(12) occurs 6.
		05 wae-touel-g-totals.
		    07 wae-touel-g-tot		pic s9(12) occurs 6.
		05 wae-uelplus-g-totals.
		    07 wae-uelplus-g-tot	pic s9(12) occurs 6.
		05 wae-niable-s-totals.
		    07 wae-niable-s-tot		pic s9(12) occurs 6.
		05 wae-tolel-s-totals.
		    07 wae-tolel-s-tot		pic s9(12) occurs 6.
		05 wae-toet-s-totals.
		    07 wae-toet-s-tot		pic s9(12) occurs 6.
		05 wae-touap-s-totals.
		    07 wae-touap-s-tot		pic s9(12) occurs 6.
		05 wae-touel-s-totals.
		    07 wae-touel-s-tot		pic s9(12) occurs 6.
		05 wae-uelplus-s-totals.
		    07 wae-uelplus-s-tot	pic s9(12) occurs 6.
		05 wae-niable-l-totals.
		    07 wae-niable-l-tot		pic s9(12) occurs 6.
		05 wae-tolel-l-totals.
		    07 wae-tolel-l-tot		pic s9(12) occurs 6.
		05 wae-toet-l-totals.
		    07 wae-toet-l-tot		pic s9(12) occurs 6.
		05 wae-touap-l-totals.
		    07 wae-touap-l-tot		pic s9(12) occurs 6.
		05 wae-touel-l-totals.
		    07 wae-touel-l-tot		pic s9(12) occurs 6.
		05 wae-uelplus-l-totals.
		    07 wae-uelplus-l-tot	pic s9(12) occurs 6.
		05 wae-niable-j-totals.
		    07 wae-niable-j-tot		pic s9(12) occurs 6.
		05 wae-tolel-j-totals.
		    07 wae-tolel-j-tot		pic s9(12) occurs 6.
		05 wae-toet-j-totals.
		    07 wae-toet-j-tot		pic s9(12) occurs 6.
		05 wae-touap-j-totals.
		    07 wae-touap-j-tot		pic s9(12) occurs 6.
		05 wae-touel-j-totals.
		    07 wae-touel-j-tot		pic s9(12) occurs 6.
		05 wae-uelplus-j-totals.
		    07 wae-uelplus-j-tot	pic s9(12) occurs 6.
	    03 wae-niable-depts.
		05 wae-d-nitot-totals.
		    07 wae-d-nitot-pay		pic s9(12) occurs 6.
		05 wae-d-niable-a-totals.
		    07 wae-d-niable-a-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-a-totals.
		    07 wae-d-tolel-a-tot	pic s9(12) occurs 6.
		05 wae-d-toet-a-totals.
		    07 wae-d-toet-a-tot		pic s9(12) occurs 6.
		05 wae-d-touap-a-totals.
		    07 wae-d-touap-a-tot	pic s9(12) occurs 6.
		05 wae-d-touel-a-totals.
		    07 wae-d-touel-a-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-a-totals.
		    07 wae-d-uelplus-a-tot	pic s9(12) occurs 6.
		05 wae-d-niable-b-totals.
		    07 wae-d-niable-b-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-b-totals.
		    07 wae-d-tolel-b-tot	pic s9(12) occurs 6.
		05 wae-d-toet-b-totals.
		    07 wae-d-toet-b-tot		pic s9(12) occurs 6.
		05 wae-d-touap-b-totals.
		    07 wae-d-touap-b-tot	pic s9(12) occurs 6.
		05 wae-d-touel-b-totals.
		    07 wae-d-touel-b-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-b-totals.
		    07 wae-d-uelplus-b-tot	pic s9(12) occurs 6.
		05 wae-d-niable-c-totals.
		    07 wae-d-niable-c-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-c-totals.
		    07 wae-d-tolel-c-tot	pic s9(12) occurs 6.
		05 wae-d-toet-c-totals.
		    07 wae-d-toet-c-tot		pic s9(12) occurs 6.
		05 wae-d-touap-c-totals.
		    07 wae-d-touap-c-tot	pic s9(12) occurs 6.
		05 wae-d-touel-c-totals.
		    07 wae-d-touel-c-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-c-totals.
		    07 wae-d-uelplus-c-tot	pic s9(12) occurs 6.
		05 wae-d-niable-d-totals.
		    07 wae-d-niable-d-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-d-totals.
		    07 wae-d-tolel-d-tot	pic s9(12) occurs 6.
		05 wae-d-toet-d-totals.
		    07 wae-d-toet-d-tot		pic s9(12) occurs 6.
		05 wae-d-touap-d-totals.
		    07 wae-d-touap-d-tot	pic s9(12) occurs 6.
		05 wae-d-touel-d-totals.
		    07 wae-d-touel-d-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-d-totals.
		    07 wae-d-uelplus-d-tot	pic s9(12) occurs 6.
		05 wae-d-niable-e-totals.
		    07 wae-d-niable-e-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-e-totals.
		    07 wae-d-tolel-e-tot	pic s9(12) occurs 6.
		05 wae-d-toet-e-totals.
		    07 wae-d-toet-e-tot		pic s9(12) occurs 6.
		05 wae-d-touap-e-totals.
		    07 wae-d-touap-e-tot	pic s9(12) occurs 6.
		05 wae-d-touel-e-totals.
		    07 wae-d-touel-e-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-e-totals.
		    07 wae-d-uelplus-e-tot	pic s9(12) occurs 6.
		05 wae-d-niable-f-totals.
		    07 wae-d-niable-f-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-f-totals.
		    07 wae-d-tolel-f-tot	pic s9(12) occurs 6.
		05 wae-d-toet-f-totals.
		    07 wae-d-toet-f-tot		pic s9(12) occurs 6.
		05 wae-d-touap-f-totals.
		    07 wae-d-touap-f-tot	pic s9(12) occurs 6.
		05 wae-d-touel-f-totals.
		    07 wae-d-touel-f-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-f-totals.
		    07 wae-d-uelplus-f-tot	pic s9(12) occurs 6.
		05 wae-d-niable-g-totals.
		    07 wae-d-niable-g-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-g-totals.
		    07 wae-d-tolel-g-tot	pic s9(12) occurs 6.
		05 wae-d-toet-g-totals.
		    07 wae-d-toet-g-tot		pic s9(12) occurs 6.
		05 wae-d-touap-g-totals.
		    07 wae-d-touap-g-tot	pic s9(12) occurs 6.
		05 wae-d-touel-g-totals.
		    07 wae-d-touel-g-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-g-totals.
		    07 wae-d-uelplus-g-tot	pic s9(12) occurs 6.
		05 wae-d-niable-s-totals.
		    07 wae-d-niable-s-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-s-totals.
		    07 wae-d-tolel-s-tot	pic s9(12) occurs 6.
		05 wae-d-toet-s-totals.
		    07 wae-d-toet-s-tot		pic s9(12) occurs 6.
		05 wae-d-touap-s-totals.
		    07 wae-d-touap-s-tot	pic s9(12) occurs 6.
		05 wae-d-touel-s-totals.
		    07 wae-d-touel-s-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-s-totals.
		    07 wae-d-uelplus-s-tot	pic s9(12) occurs 6.
		05 wae-d-niable-l-totals.
		    07 wae-d-niable-l-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-l-totals.
		    07 wae-d-tolel-l-tot	pic s9(12) occurs 6.
		05 wae-d-toet-l-totals.
		    07 wae-d-toet-l-tot		pic s9(12) occurs 6.
		05 wae-d-touap-l-totals.
		    07 wae-d-touap-l-tot	pic s9(12) occurs 6.
		05 wae-d-touel-l-totals.
		    07 wae-d-touel-l-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-l-totals.
		    07 wae-d-uelplus-l-tot	pic s9(12) occurs 6.
		05 wae-d-niable-j-totals.
		    07 wae-d-niable-j-tot	pic s9(12) occurs 6.
		05 wae-d-tolel-j-totals.
		    07 wae-d-tolel-j-tot	pic s9(12) occurs 6.
		05 wae-d-toet-j-totals.
		    07 wae-d-toet-j-tot		pic s9(12) occurs 6.
		05 wae-d-touap-j-totals.
		    07 wae-d-touap-j-tot	pic s9(12) occurs 6.
		05 wae-d-touel-j-totals.
		    07 wae-d-touel-j-tot	pic s9(12) occurs 6.
		05 wae-d-uelplus-j-totals.
		    07 wae-d-uelplus-j-tot	pic s9(12) occurs 6.
	    03 wae-niable-payroll.
		05 wae-p-nitot-totals.
		    07 wae-p-nitot-pay		pic s9(12) occurs 6.
		05 wae-p-niable-a-totals.
		    07 wae-p-niable-a-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-a-totals.
		    07 wae-p-tolel-a-tot	pic s9(12) occurs 6.
		05 wae-p-toet-a-totals.
		    07 wae-p-toet-a-tot		pic s9(12) occurs 6.
		05 wae-p-touap-a-totals.
		    07 wae-p-touap-a-tot	pic s9(12) occurs 6.
		05 wae-p-touel-a-totals.
		    07 wae-p-touel-a-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-a-totals.
		    07 wae-p-uelplus-a-tot	pic s9(12) occurs 6.
		05 wae-p-niable-b-totals.
		    07 wae-p-niable-b-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-b-totals.
		    07 wae-p-tolel-b-tot	pic s9(12) occurs 6.
		05 wae-p-toet-b-totals.
		    07 wae-p-toet-b-tot		pic s9(12) occurs 6.
		05 wae-p-touap-b-totals.
		    07 wae-p-touap-b-tot	pic s9(12) occurs 6.
		05 wae-p-touel-b-totals.
		    07 wae-p-touel-b-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-b-totals.
		    07 wae-p-uelplus-b-tot	pic s9(12) occurs 6.
		05 wae-p-niable-c-totals.
		    07 wae-p-niable-c-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-c-totals.
		    07 wae-p-tolel-c-tot	pic s9(12) occurs 6.
		05 wae-p-toet-c-totals.
		    07 wae-p-toet-c-tot		pic s9(12) occurs 6.
		05 wae-p-touap-c-totals.
		    07 wae-p-touap-c-tot	pic s9(12) occurs 6.
		05 wae-p-touel-c-totals.
		    07 wae-p-touel-c-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-c-totals.
		    07 wae-p-uelplus-c-tot	pic s9(12) occurs 6.
		05 wae-p-niable-d-totals.
		    07 wae-p-niable-d-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-d-totals.
		    07 wae-p-tolel-d-tot	pic s9(12) occurs 6.
		05 wae-p-toet-d-totals.
		    07 wae-p-toet-d-tot		pic s9(12) occurs 6.
		05 wae-p-touap-d-totals.
		    07 wae-p-touap-d-tot	pic s9(12) occurs 6.
		05 wae-p-touel-d-totals.
		    07 wae-p-touel-d-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-d-totals.
		    07 wae-p-uelplus-d-tot	pic s9(12) occurs 6.
		05 wae-p-niable-e-totals.
		    07 wae-p-niable-e-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-e-totals.
		    07 wae-p-tolel-e-tot	pic s9(12) occurs 6.
		05 wae-p-toet-e-totals.
		    07 wae-p-toet-e-tot		pic s9(12) occurs 6.
		05 wae-p-touap-e-totals.
		    07 wae-p-touap-e-tot	pic s9(12) occurs 6.
		05 wae-p-touel-e-totals.
		    07 wae-p-touel-e-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-e-totals.
		    07 wae-p-uelplus-e-tot	pic s9(12) occurs 6.
		05 wae-p-niable-f-totals.
		    07 wae-p-niable-f-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-f-totals.
		    07 wae-p-tolel-f-tot	pic s9(12) occurs 6.
		05 wae-p-toet-f-totals.
		    07 wae-p-toet-f-tot		pic s9(12) occurs 6.
		05 wae-p-touap-f-totals.
		    07 wae-p-touap-f-tot	pic s9(12) occurs 6.
		05 wae-p-touel-f-totals.
		    07 wae-p-touel-f-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-f-totals.
		    07 wae-p-uelplus-f-tot	pic s9(12) occurs 6.
		05 wae-p-niable-g-totals.
		    07 wae-p-niable-g-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-g-totals.
		    07 wae-p-tolel-g-tot	pic s9(12) occurs 6.
		05 wae-p-toet-g-totals.
		    07 wae-p-toet-g-tot		pic s9(12) occurs 6.
		05 wae-p-touap-g-totals.
		    07 wae-p-touap-g-tot	pic s9(12) occurs 6.
		05 wae-p-touel-g-totals.
		    07 wae-p-touel-g-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-g-totals.
		    07 wae-p-uelplus-g-tot	pic s9(12) occurs 6.
		05 wae-p-niable-s-totals.
		    07 wae-p-niable-s-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-s-totals.
		    07 wae-p-tolel-s-tot	pic s9(12) occurs 6.
		05 wae-p-toet-s-totals.
		    07 wae-p-toet-s-tot		pic s9(12) occurs 6.
		05 wae-p-touap-s-totals.
		    07 wae-p-touap-s-tot	pic s9(12) occurs 6.
		05 wae-p-touel-s-totals.
		    07 wae-p-touel-s-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-s-totals.
		    07 wae-p-uelplus-s-tot	pic s9(12) occurs 6.
		05 wae-p-niable-l-totals.
		    07 wae-p-niable-l-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-l-totals.
		    07 wae-p-tolel-l-tot	pic s9(12) occurs 6.
		05 wae-p-toet-l-totals.
		    07 wae-p-toet-l-tot		pic s9(12) occurs 6.
		05 wae-p-touap-l-totals.
		    07 wae-p-touap-l-tot	pic s9(12) occurs 6.
		05 wae-p-touel-l-totals.
		    07 wae-p-touel-l-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-l-totals.
		    07 wae-p-uelplus-l-tot	pic s9(12) occurs 6.
		05 wae-p-niable-j-totals.
		    07 wae-p-niable-j-tot	pic s9(12) occurs 6.
		05 wae-p-tolel-j-totals.
		    07 wae-p-tolel-j-tot	pic s9(12) occurs 6.
		05 wae-p-toet-j-totals.
		    07 wae-p-toet-j-tot		pic s9(12) occurs 6.
		05 wae-p-touap-j-totals.
		    07 wae-p-touap-j-tot	pic s9(12) occurs 6.
		05 wae-p-touel-j-totals.
		    07 wae-p-touel-j-tot	pic s9(12) occurs 6.
		05 wae-p-uelplus-j-totals.
		    07 wae-p-uelplus-j-tot	pic s9(12) occurs 6.
	    03 wae-ees-totals.
		05 wae-ees-a-totals.
		    07 wae-ees-a-tot		pic s9(12) occurs 6.
		05 wae-ees-b-totals.
		    07 wae-ees-b-tot		pic s9(12) occurs 6.
		05 wae-ees-c-totals.
		    07 wae-ees-c-tot		pic s9(12) occurs 6.
		05 wae-ees-d-totals.
		    07 wae-ees-d-tot		pic s9(12) occurs 6.
		05 wae-ees-e-totals.
		    07 wae-ees-e-tot		pic s9(12) occurs 6.
		05 wae-ees-f-totals.
		    07 wae-ees-f-tot		pic s9(12) occurs 6.
		05 wae-ees-g-totals.
		    07 wae-ees-g-tot		pic s9(12) occurs 6.
		05 wae-ees-s-totals.
		    07 wae-ees-s-tot		pic s9(12) occurs 6.
		05 wae-ees-l-totals.
		    07 wae-ees-l-tot		pic s9(12) occurs 6.
		05 wae-ees-j-totals.
		    07 wae-ees-j-tot		pic s9(12) occurs 6.
	    03 wae-ees-dept-totals.
		05 wae-d-ees-a-totals.
		    07 wae-d-ees-a-tot		pic s9(12) occurs 6.
		05 wae-d-ees-b-totals.
		    07 wae-d-ees-b-tot		pic s9(12) occurs 6.
		05 wae-d-ees-c-totals.
		    07 wae-d-ees-c-tot		pic s9(12) occurs 6.
		05 wae-d-ees-d-totals.
		    07 wae-d-ees-d-tot		pic s9(12) occurs 6.
		05 wae-d-ees-e-totals.
		    07 wae-d-ees-e-tot		pic s9(12) occurs 6.
		05 wae-d-ees-f-totals.
		    07 wae-d-ees-f-tot		pic s9(12) occurs 6.
		05 wae-d-ees-g-totals.
		    07 wae-d-ees-g-tot		pic s9(12) occurs 6.
		05 wae-d-ees-s-totals.
		    07 wae-d-ees-s-tot		pic s9(12) occurs 6.
		05 wae-d-ees-l-totals.
		    07 wae-d-ees-l-tot		pic s9(12) occurs 6.
		05 wae-d-ees-j-totals.
		    07 wae-d-ees-j-tot		pic s9(12) occurs 6.
	    03 wae-ees-payroll-totals.
		05 wae-p-ees-a-totals.
		    07 wae-p-ees-a-tot		pic s9(12) occurs 6.
		05 wae-p-ees-b-totals.
		    07 wae-p-ees-b-tot		pic s9(12) occurs 6.
		05 wae-p-ees-c-totals.
		    07 wae-p-ees-c-tot		pic s9(12) occurs 6.
		05 wae-p-ees-d-totals.
		    07 wae-p-ees-d-tot		pic s9(12) occurs 6.
		05 wae-p-ees-e-totals.
		    07 wae-p-ees-e-tot		pic s9(12) occurs 6.
		05 wae-p-ees-f-totals.
		    07 wae-p-ees-f-tot		pic s9(12) occurs 6.
		05 wae-p-ees-g-totals.
		    07 wae-p-ees-g-tot		pic s9(12) occurs 6.
		05 wae-p-ees-s-totals.
		    07 wae-p-ees-s-tot		pic s9(12) occurs 6.
		05 wae-p-ees-l-totals.
		    07 wae-p-ees-l-tot		pic s9(12) occurs 6.
		05 wae-p-ees-j-totals.
		    07 wae-p-ees-j-tot		pic s9(12) occurs 6.
	    03 wae-ers-totals.
		05 wae-ersni-a-totals.
		    07 wae-ersni-a-tot		pic s9(12) occurs 6.
		05 wae-ersni-b-totals.
		    07 wae-ersni-b-tot		pic s9(12) occurs 6.
		05 wae-ersni-c-totals.
		    07 wae-ersni-c-tot		pic s9(12) occurs 6.
		05 wae-ersni-d-totals.
		    07 wae-ersni-d-tot		pic s9(12) occurs 6.
		05 wae-ersni-e-totals.
		    07 wae-ersni-e-tot		pic s9(12) occurs 6.
		05 wae-ersni-f-totals.
		    07 wae-ersni-f-tot		pic s9(12) occurs 6.
		05 wae-ersni-g-totals.
		    07 wae-ersni-g-tot		pic s9(12) occurs 6.
		05 wae-ersni-s-totals.
		    07 wae-ersni-s-tot		pic s9(12) occurs 6.
		05 wae-ersni-l-totals.
		    07 wae-ersni-l-tot		pic s9(12) occurs 6.
		05 wae-ersni-j-totals.
		    07 wae-ersni-j-tot		pic s9(12) occurs 6.
		05 wae-ersni-p-totals.
		    07 wae-ersni-p-tot		pic s9(12) occurs 6.
		05 wae-ersreb-d-totals.
		    07 wae-ersreb-d-tot		pic s9(12) occurs 6.
		05 wae-ersreb-e-totals.
		    07 wae-ersreb-e-tot		pic s9(12) occurs 6.
		05 wae-ersreb-f-totals.
		    07 wae-ersreb-f-tot		pic s9(12) occurs 6.
		05 wae-ersreb-g-totals.
		    07 wae-ersreb-g-tot		pic s9(12) occurs 6.
		05 wae-ersreb-s-totals.
		    07 wae-ersreb-s-tot		pic s9(12) occurs 6.
		05 wae-ersreb-l-totals.
		    07 wae-ersreb-l-tot		pic s9(12) occurs 6.
		05 wae-eesreb-d-totals.
		    07 wae-eesreb-d-tot		pic s9(12) occurs 6.
		05 wae-eesreb-f-totals.
		    07 wae-eesreb-f-tot		pic s9(12) occurs 6.
	    03 wae-ersni-dept-totals.
		05 wae-d-ersni-a-totals.
		    07 wae-d-ersni-a-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-b-totals.
		    07 wae-d-ersni-b-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-c-totals.
		    07 wae-d-ersni-c-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-d-totals.
		    07 wae-d-ersni-d-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-e-totals.
		    07 wae-d-ersni-e-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-f-totals.
		    07 wae-d-ersni-f-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-g-totals.
		    07 wae-d-ersni-g-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-s-totals.
		    07 wae-d-ersni-s-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-l-totals.
		    07 wae-d-ersni-l-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-j-totals.
		    07 wae-d-ersni-j-tot	pic s9(12) occurs 6.
		05 wae-d-ersni-p-totals.
		    07 wae-d-ersni-p-tot	pic s9(12) occurs 6.
		05 wae-d-ersreb-d-totals.
		    07 wae-d-ersreb-d-tot	pic s9(12) occurs 6.
		05 wae-d-ersreb-e-totals.
		    07 wae-d-ersreb-e-tot	pic s9(12) occurs 6.
		05 wae-d-ersreb-f-totals.
		    07 wae-d-ersreb-f-tot	pic s9(12) occurs 6.
		05 wae-d-ersreb-g-totals.
		    07 wae-d-ersreb-g-tot	pic s9(12) occurs 6.
		05 wae-d-ersreb-s-totals.
		    07 wae-d-ersreb-s-tot	pic s9(12) occurs 6.
		05 wae-d-ersreb-l-totals.
		    07 wae-d-ersreb-l-tot	pic s9(12) occurs 6.
		05 wae-d-eesreb-d-totals.
		    07 wae-d-eesreb-d-tot	pic s9(12) occurs 6.
		05 wae-d-eesreb-f-totals.
		    07 wae-d-eesreb-f-tot	pic s9(12) occurs 6.
	    03 wae-ersni-payroll-totals.
		05 wae-p-ersni-a-totals.
		    07 wae-p-ersni-a-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-b-totals.
		    07 wae-p-ersni-b-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-c-totals.
		    07 wae-p-ersni-c-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-d-totals.
		    07 wae-p-ersni-d-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-e-totals.
		    07 wae-p-ersni-e-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-f-totals.
		    07 wae-p-ersni-f-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-g-totals.
		    07 wae-p-ersni-g-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-s-totals.
		    07 wae-p-ersni-s-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-l-totals.
		    07 wae-p-ersni-l-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-j-totals.
		    07 wae-p-ersni-j-tot	pic s9(12) occurs 6.
		05 wae-p-ersni-p-totals.
		    07 wae-p-ersni-p-tot	pic s9(12) occurs 6.
		05 wae-p-ersreb-d-totals.
		    07 wae-p-ersreb-d-tot	pic s9(12) occurs 6.
		05 wae-p-ersreb-e-totals.
		    07 wae-p-ersreb-e-tot	pic s9(12) occurs 6.
		05 wae-p-ersreb-f-totals.
		    07 wae-p-ersreb-f-tot	pic s9(12) occurs 6.
		05 wae-p-ersreb-g-totals.
		    07 wae-p-ersreb-g-tot	pic s9(12) occurs 6.
		05 wae-p-ersreb-s-totals.
		    07 wae-p-ersreb-s-tot	pic s9(12) occurs 6.
		05 wae-p-ersreb-l-totals.
		    07 wae-p-ersreb-l-tot	pic s9(12) occurs 6.
		05 wae-p-eesreb-d-totals.
		    07 wae-p-eesreb-d-tot	pic s9(12) occurs 6.
		05 wae-p-eesreb-f-totals.
		    07 wae-p-eesreb-f-tot	pic s9(12) occurs 6.
	    03 wae-net-totals.
		05 wae-net-pay			pic s9(12) occurs 6.
	    03 wae-diff-totals.
		05 wae-diff-pay			pic s9(12) occurs 6.
	    03 wae-948-net.
		05 wae-948-net-pay		pic s9(12) occurs 6.
	    03 wae-summary-payroll-totals.
		05 wae-p-summ			pic s9(12) occurs 16.

      ******************************************************************
      //////////////////////////////////////////////////////////////////

	01 waf-underline.
	    03 filler				pic x(28).
	    03 waf-line			occurs 6.
		05 filler			pic x(13) value
			"-------------".
		05 filler			pic x(5).

	01 waf-sex.
	    03 waf-gender			pic x.
	    03 filler				pic xxx.

	01 waf-data-code.
	    03 waf-code				pic xxx.
	    03 filler				pic x.

	01 waf-pay-rec-save.
	    03 waf-descrip-save.
		05 filler			pic x(25).
	    03 waf-data-save.
		05 waf-data-col-save	occurs 6.
		    07 filler			pic s9(12).

	01 waf-spec-code.
	    03 filler				pic x.
	    03 waf-spec-val			pic xxx.

	01 waf-pay-rec.
	    03 waf-descrip.
		05 filler			pic x.
		05 waf-pay-ded			pic x(4).
		05 filler			pic x.
		05 waf-desc-name		pic x(18).
	    03 waf-rec-type			pic x.
	    03 waf-data.
		05 waf-data-col		occurs 6.
		    07 waf-data-column		pic s9(12).

	01 waf-divisionals.
	    03 waf-smp-rec-perc			pic s9(3)v99.
	    03 waf-ssp-rec-perc			pic s9(3)v99.
	    03 waf-rec-perc			pic s9(3)v99.
	    03 waf-smp-cmp-perc			pic s9(3)v9(6).
	    03 waf-rnd-up-value			pic 9v9.
	    03 waf-divide			pic s9(10)v99.
	    03 waf-divide2			pic s9(9)v999.
	    03 waf-divide3			pic s9v9.
	    03 waf-div-anal.
		05 waf-div-whole.
		    07 waf-div-main		pic s9(9).
		    07 waf-div-dec		pic v9.
		05 waf-div-dec2			pic 9(2).
	    03 waf-div-anal2.
		05 filler			pic s9(9).
		05 filler			pic v9.
		05 waf-div-dec-test		pic 9(2).

	01 waf-smp-rec-fmt			pic zzz.zz.

	01 waf-fmt-line.	
	    03 filler				pic x(4).
	    03 waf-fmt-cols		occurs 6.
		05 waf-fmt-column.
		    07 waf-fmt-value		pic z(9)9.99-.
		05 filler			pic x(4).
	    03 filler				pic x(40).

	01 waf-fmt-line-1			redefines waf-fmt-line.
	    03 filler				pic x(11).
	    03 waf-summ1-amt			pic z(9)9.99- occurs 6.
	    03 filler				pic x(37).

	01 waf-fmt-line-2			redefines waf-fmt-line.
	    03 waf-summ-td			pic x(3).
	    03 filler				pic x.
	    03 waf-summ-ref			pic x(7).
	    03 filler				pic x(2).
	    03 waf-summ-amt			pic z(8)9.99- occurs 9.

	01 waf-current-alpha			pic x(30).

	01 waf-print-line			pic x(132).

	01 waf-mits-data.
	    03 waf-fv-function			pic x value "1".
	    03 waf-fz-function			pic x value "2".
	    03 waf-fu-function			pic x value "3".
	    03 waf-fv-run-date	 		pic 9(8).
	    03 waf-fz-run-date			pic 9(8).
	    03 waf-fu-run-date			pic 9(8).

      ******************************************************************
      //////////////////////////////////////////////////////////////////

	01 wag-data-numbers.
	    03 wag-data-num1.
		05 wag-number1		occurs 6.
		    07 wag-num1-col		pic s9(12).
	    03 wag-data-num2.
		05 wag-number2		occurs 6.
		    07 wag-num2-col		pic s9(12).

	01 wah-ni-str.
	    03 filler				pic x(6).
	    03 wah-ni-tab			pic x(4).

	01 waj-last-fab-emp			pic x(8).

	01 wak-cash-amt				pic s9(12).

	01 wal-coin-analysis.
	    03 wal-pnds-rem			pic 9(2).
	    03 wal-pnce-rem			pic 9(2).
	    03 wal-csh-rem			pic 9(2).
	    03 wal-net-pay.
		05 wal-pounds			pic s9(10).
		05 wal-pence			pic 9(2).
	    03 wal-cash-group.
		05 wal-50-cnt			pic 9(5).
		05 wal-20-cnt			pic 9(5).
		05 wal-10-cnt			pic 9(5).
		05 wal-5-cnt			pic 9(5).
		05 wal-1-cnt			pic 9(5).
		05 wal-50p-cnt			pic 9(5).
		05 wal-20p-cnt			pic 9(5).
		05 wal-10p-cnt			pic 9(5).
		05 wal-5p-cnt			pic 9(5).
		05 wal-2p-cnt			pic 9(5).
		05 wal-1p-cnt			pic 9(5).

	01 wam-months.
	    03 filler			pic x(12) value "April".
	    03 filler			pic x(12) value "May".
	    03 filler			pic x(12) value "June".
	    03 filler			pic x(12) value "July".
	    03 filler			pic x(12) value "August".
	    03 filler			pic x(12) value "September".
	    03 filler			pic x(12) value "October".
	    03 filler			pic x(12) value "November".
	    03 filler			pic x(12) value "December".
	    03 filler			pic x(12) value "January".
	    03 filler			pic x(12) value "February".
	    03 filler			pic x(12) value "March".

	01 wam-months-redef redefines wam-months.
	    03 wam-month	occurs 12	pic x(12).

	01 wzz-file-value			pic xx.

	01 wza-neg				pic 9.
		88 neg-num value 1.

	01 wza-pcent-result			pic 9(9)v9(4).

	01 wza-rd redefines wza-pcent-result.
	    03 filler				pic x(11).
	    03 wza-dps				pic 9(2).

      ***********************************************************************
      ///////////////////////////////////////////////////////////////////////
	procedure division.

	declaratives.

		copy "fa.dec".
		copy "fb.dec".
		copy "fe.dec".
		copy "fj.dec".
		copy "fu.dec".
		copy "fv.dec".
		copy "fy.dec".
		copy "fz.dec".
		copy "fzc.dec".
		copy "fze.dec".
		copy "fzf.dec".
		copy "fzl.dec".
		copy "fzq.dec".

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	pa-err							section.
		use after error procedure on paa-prt-fl.

	paerr.
		if wzz-io-err-code = zero
			move "PRINT" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	f1-err							section.
		use after error procedure on fa-pay-fl.

	f1err.
		if wzz-io-err-code = zero
			move "SUBDPAY" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	f2-err							section.
		use after error procedure on fb-pay-fl.

	f2err.
		if wzz-io-err-code = zero
			move "DEPTPAY" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	f3-err							section.
		use after error procedure on fc-pay-fl.

	f3err.
		if wzz-io-err-code = zero
			move "PRPAY" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	fd-err							section.
		use after error procedure on fd-summ-fl.

	fderr.
		if wzz-io-err-code = zero
			move "SUMMARY" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	fcf-err							section.
		use after error procedure on ff-coinage-fl.

	fcferr.
		if wzz-io-err-code = zero
			move "COINAGE" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ft-err							section.
		use after error procedure on ft-tran-fl.

	fterr.
		if wzz-io-err-code = zero
			move "TRANCOPY" to wzz-file-name
			call "mits01vc" using
				wzz-file-status
				wzz-io-err-code
				wzz-file-name.

	end declaratives.

      **| CONTEXT |******************************************************
      * Design for aa-main taken from CPRS6000 Context Design.		*
      * labels have Design State Number on end ie s0.			*
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	aa-main							section.

	aa000-start.
		display wa-prog-ref.
		open output paa-prt-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	aa100-loop.
		perform ba-open-files.
		perform bb-init-cnts.
		perform bc-header-setup.
		perform bd-printer-fl until waa-eof-flag not = zero.
		perform yn-footer-line.
		perform be-close-files.
		if waa-special-split not = zero
			if waa-scan = zero
				add 1 to waa-scan
				go to aa100-loop.
		close paa-prt-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	aa999-exit.
		stop run.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ba-open-files						section.

	ba000-start.
		move zero to waa-flags.
		open input fb-employee-variables.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fu-user-header-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fv-variables-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fz-variables-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fy-system-header-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fzf-tax-districts.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fj-transfers.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fa-employee-header.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open output ft-tran-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close ft-tran-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o ft-tran-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fzq-file.
		if wzz-io-err-code = zero
			move 1 to waa-fzq-present
			else
			move zero to wzz-io-err-code.
		move zero to fzqa-rec.

	ba999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	bb-init-cnts						section.

	bb000-start.
		move zero to
			wae-totalling
			wab-subscripts
			wac-cash-amt
			wac-other-amt
			wac-bank-amt
			wal-coin-analysis
			wac-csh-totals.
		move all "_" to
			wad-norm-code
			wad-split-fja-key
			wad-save-last-key
			wad-save-new-key
			wad-save-values.
		move spaces to
			waf-fmt-line
			waf-current-alpha
			waf-print-line.
		move 60 to
			wab-page-len
			wab-line-cnt.
		move 1 to wab-spacing.
		move 1 to waa-emp-change.
		move zero to faa-key.
		read fa-employee-header record into fac-rec
			invalid key
			initialize fac-rec.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fac-pay-date to
			wab-date
			wab-tax-date
			waf-fu-run-date
			waf-fz-run-date
			waf-fv-run-date.
		if fac-pay-date < wa-use-nicalc5-date
			move zero to waa-use-nicalc5-mkr
			else
			move 1 to waa-use-nicalc5-mkr.
           if fac-pay-date > "20100405" 
               move "TOPT" to wad-ni-nar1
           end-if.
		move 63 to wza-max-page-lines.
		move fac-run-sequence-no to wza-run-number.
		call "mits01vz" using
			waf-fv-run-date
			waf-fv-function.
		call "mits01vz" using
			waf-fz-run-date
			waf-fz-function.
		call "mits01vz" using
			waf-fu-run-date
			waf-fu-function.
		cancel "mits01vz".
		move fac-tax-period to wac-tax-period.
		string wab-dd wab-month-str(wab-mm) wab-yy
			delimited by size into wac-prt-date.
		open output fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open output fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open output fc-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fc-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o fc-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move zero to wzz-io-err-code.

	bb010-loop.
		read fj-transfers next record at end
			close fj-transfers
			go to bb999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fja-transfer-to-ref to ftr-key.
		write ft-tran-record.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		go to bb010-loop.

	bb999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	bc-header-setup						section.

	bc000-start.
		read fu-user-header-glossary
			at end
			go to bc999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if fub-date not = waf-fu-run-date
			go to bc000-start.

	bc001-set-fyb-defaults.
		move 100 to waf-smp-rec-perc waf-smp-rec-fmt.
		move 0.00045 to waf-smp-cmp-perc.
		move 0.5 to waf-rnd-up-value.

	bc003-get-fy-details.
		read fy-system-header-glossary next record
			at end
			go to bc005-set-data.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if fyb-date <= fac-pay-date
		    if fyb-smp-recovery not = spaces
				if fyb-smp-recovery not = zero
					move fyb-smp-recovery to
						waf-smp-rec-perc
						waf-smp-rec-fmt
				end-if
			end-if
			if fyb-ssp-rec-rnd-up not = spaces
				if fyb-ssp-rec-rnd-up not = zero
					move fyb-ssp-rec-rnd-up to
						waf-rnd-up-value
				end-if
			end-if
		    if fyb-smp-nic not = spaces
		    	if fyb-smp-nic not = zero
		    		move fyb-smp-nic to waf-smp-cmp-perc
		    		divide waf-smp-cmp-perc by 10000
					giving waf-smp-cmp-perc
			        end-if
			end-if
		    if fyb-ssp-recovery not = spaces
			    if fyb-ssp-recovery not = zero
				move fyb-ssp-recovery to
					waf-ssp-rec-perc
			    end-if
		    end-if
		go to bc003-get-fy-details
		end-if.

	bc005-set-data.
		if fub-extra-opts(9) < "1" or > "6"
			or waa-scan not = zero
				move zero to waa-special-split
				else
				move 1 to waa-special-split.
		if fub-special-summary = 1
			move 1 to waa-special-prt.
		if fub-summary-laser-throw = 1
			move 1 to waa-laser-throw.
		move zero to waf-ssp-rec-perc.
		move fub-user-name to wac-user-name.
		move fub-user to wac-user-no wza-user.
		move wa-prog-ref to wza-prog-id.
		if waa-scan not = zero
			move zero to fub-sub-dept-analysis
			move zero to fub-cost-code-summary
			move "1" to fub-dept-analysis.
		if fub-sub-dept-analysis = "1"
			if fub-dept-analysis = "0"
				move "1" to fub-dept-analysis.
		if fub-cost-code-summary = 1
			move "COST    " to wac-sub-str
			move 1 to waa-code-break
			if waa-special-split = zero
				call "mits01iz" using wab-ord-str
				cancel "mits01iz"
				else
				perform cj-create-tag.
		if waa-code-break not = zero
			open i-o fe-tag-file
			perform ci-update-fe-trans.
      *	below is to check if fzlfile is present ...
		open input fzl-file.
		if wzz-io-err-code = zero
			close fzl-file
			if fub-dept-analysis = "0"
				move zero to waa-summ-flag
				go to bc999-exit
				else
				move 2 to waa-summ-flag
				go to bc900-par.
		move zero to wzz-io-err-code.
		if fub-multi-tax-depts not = "1"
			go to bc999-exit.
		if fub-dept-analysis = "0"
			go to bc999-exit.
		open input fzc-multi-tax-depts.
		if wzz-io-err-code not = zero
			move zero to wzz-io-err-code
			go to bc999-exit.
		move 1 to waa-summ-flag.

	bc900-par.
		open output fd-summ-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fd-summ-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o fd-summ-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	bc999-exit.
		exit.

      **| STATE S3 |*****************************************************
      * BD-PRINTER-FL.							*
      *   This section, runs down the FBFILE. It totals up the data	*
      *   codes by SUB-DEPT and DEPT. Payments/Deductions are out sort	*
      *   ed to a temporary file to be printed at the end (in order)	*
      *   of the sub-dept/ dept.					*
      *									*
      *   Not all state design numbers are shown to give way to the	*
      *   software sequence clarity.					*
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	bd-printer-fl						section.

	bd000-start.
		move zero to waa-cost-break.

	bd003-read-emp.
		perform ch-read-fe-or-fb.
		if fbb-data-code not numeric
			if waa-eof-flag = zero
				go to bd003-read-emp.
		if wab-read-mkr = zero
			move 1 to wab-read-mkr
			move fbb-dept to wad-save-dept
			move fbb-sub-dept to wad-save-sub
			if waa-code-break not = zero
				move wad-cost-str to wad-save-sub-long
				move wad-cost-dept to wad-save-dept
			 	move fea-tag-key to wad-save-last-key.
		if waa-code-break = zero
			if fbb-sub-dept not = wad-save-sub
				or fbb-dept not = wad-save-dept
				perform ca-sub-print
				move fbb-sub-dept to wad-save-sub
				if fbb-dept not = wad-save-dept
					perform cc-dept-print
					move fbb-dept to wad-save-dept.
		if waa-code-break not = zero
			if waa-cost-break not = zero
				perform ca-sub-print
			 	if waa-cost-break = 2
		    			perform cc-dept-print
					move wad-cost-dept to
						wad-save-dept
			 	end-if
			 	move wad-cost-str to wad-save-sub-long
			 	move zero to waa-cost-break
			 	move fea-tag-key to wad-save-last-key.
		if waa-eof-flag not = zero
			perform cd-pay-print
			go to bd999-exit.
		move fbb-data-code to wad-shuffle-code.
		if wad-fbb-key not = faa-key
			move wad-fbb-key to faa-key
			read fa-employee-header
				invalid key
				initialize fab-rec
				move wad-fbb-key to faa-key.
		if wad-shuffle-code = "7920"
			if fab-nihol-mkr < 2
				go to bd999-exit.
		perform ce-total-rec.
		perform cf-save-pay-ded.

	bd999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	be-close-files						section.

	be000-start.
		close fu-user-header-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fv-variables-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fz-variables-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fb-employee-variables.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fy-system-header-glossary.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fzf-tax-districts.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fa-employee-header.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close ft-tran-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fc-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if waa-code-break not = zero
			close fe-tag-file
			if wzz-io-err-code not = zero
				perform zza-io-err.
		if waa-fzq-present not = zero
			close fzq-file
			if wzz-io-err-code not = zero
				perform zza-io-err.
		if waa-summ-flag not = zero
			close fd-summ-fl
			if wzz-io-err-code not = zero
				perform zza-io-err.
		if waa-summ-flag = 1
			close fzc-multi-tax-depts
			if wzz-io-err-code not = zero
				perform zza-io-err.
		if waa-coinage-mkr not = zero
			close ff-coinage-fl
			if wzz-io-err-code not = zero
				perform zza-io-err.

	be999-exit.
		exit.

      **| STATE S3.3 |***************************************************
      *  CA-SUB-PRINT.							*
      *    Using the file created by CF-SAVE-PAY-DED, this section	*
      *    prints out the data in the specified format. At this stage	*
      *    the data relates to SUB DEPT data only. This section also	*
      *    updates the DEPT cnts/totals and clears down the SUB DEPT	*
      *    ready for the next SUB DEPT run. But first the SUB DEPT	*
      *    file is written away to a DEPT file, in order for further	*
      *    levels of printing at the changeover of a DEPT.		*
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ca-sub-print						section.

	ca000-start.
		move 1 to wab-throw-mkr.
		move 1 to waa-print-flag.
		move wae-eesni-totals to wag-data-num1.
		move wae-ded-totals to wag-data-num2.
		perform zx-add-subtract.
		move wae-tax-tax to wag-data-num1.
		perform zx-add-subtract.
		move wag-data-num2 to wae-ded-totals.
		move spaces to fab-employee.
		if waa-code-break = zero
			move wad-save-dept to fab-dept
			move wad-save-sub to fab-sub-dept
		else
			move wad-last-dept to fab-dept
			move wad-last-sub-dept to fab-sub-dept.
		perform ze-fafile-dets.
		perform da-write-dept-file.
		if fub-sub-dept-analysis = "0"
			go to ca055-update-dept.
		perform ya-pay-prt.
		perform yb-ded-prt.
		perform yc-tax-prt.
		perform yd-ni-prt.
		perform ye-dss-prt.
		perform yg-3rd-prt.
		perform yj-notionals.
		perform yh-mth-prt.
		perform yi-csh-prt.

	ca055-update-dept.
		perform db-upd-dept-totes.
		perform dc-clear-sub-file.

	ca999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	cc-dept-print						section.

	cc000-start.
		move wae-d-ded-totals to wae-ded-totals.
		move wae-d-eesni-totals to wae-eesni-totals.
		move wae-d-ftc-totals to wae-ftc-totals.
		move wae-d-tax-tax to wae-tax-tax.
		move 1 to wab-throw-mkr.
		move 2 to waa-print-flag.
		perform df-write-payroll-file.
		if fub-dept-analysis = "0"
			go to cc055-update-dept.
		perform ya-pay-prt.
		perform yb-ded-prt.
		perform yc-tax-prt.
		perform yd-ni-prt.
		perform ye-dss-prt.
		perform yg-3rd-prt.
		perform yj-notionals.
		perform yh-mth-prt.
		perform yi-csh-prt.
		move 1 to waa-end-totes.

	cc055-update-dept.
		perform dg-upd-payroll-totes.
		perform dh-clear-dept-file.

	cc999-exit.
		exit.
			
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	cd-pay-print						section.

	cd000-start.
		move wae-p-ded-totals to wae-ded-totals.
		move wae-p-eesni-totals to wae-eesni-totals.
		move wae-p-ftc-totals to wae-ftc-totals.
		move wae-p-tax-tax to wae-tax-tax.
		move 1 to wab-throw-mkr.
		move 3 to waa-print-flag.
		perform ze-fafile-dets.
		perform ya-pay-prt.
		perform yb-ded-prt.
		perform yc-tax-prt.
		perform yd-ni-prt.
		perform ye-dss-prt.
		perform yg-3rd-prt.
		perform yj-notionals.
		perform yh-mth-prt.
		perform yi-csh-prt.
		perform xe-ssp-ni-line.
		if waa-special-split = zero
			if waa-use-nicalc5-mkr = zero
				perform xh-print-dss-summary
				else
				perform xj-print-dss-summary.

	cd999-exit.
		exit.
			
      **| STATE S3.10 |**************************************************
      *  CE-TOTAL-REC.							*
      *    This section keeps track of all cnts and totals. First it	*
      *    establishes a type for each data code and then decides	*
      *    upon the variable to be updated acording to the type.	*
      *									*
      *    NOTE : STATUS 35 DATA Has A Value In ADJUST And An 'F' In	*
      *           The RESET MKR.					*
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ce-total-rec						section.

	ce000-start.
		move zero to wag-data-numbers.
		perform dd-code-type.
		if wab-code-type = zero
			go to ce999-exit.
		if waa-code-break = zero
			move zero to waa-emp-change
			if wad-save-emp not = fbb-employee
				perform cg-tran-new
				move fbb-employee to wad-save-emp
				move 1 to waa-emp-change.
		perform dj-calc-columns.
		go to
			ce005-payment
			ce010-deduction
			ce015-tax
			ce020-ni
			ce025-dss
			ce999-exit
			ce035-3rd-party
			ce040-net-pay-calc
			ce045-calc-notions
				depending on wab-code-type.
		go to ce999-exit.

	ce005-payment.
		move wae-gross-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-gross-totals.
		if waa-special-prt = zero
			go to ce005-payment-1.
		if wad-code not < "080" and not > "123"
		    	move wae-n81-n123-tots to wag-data-num2
		    	perform zx-add-subtract
		    	move wag-data-num2 to wae-n81-n123-tots.
		if wad-code not < "124" and not > "167"
			move wae-n125-n167-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-n125-n167-tots.
		if wad-code not < "168" and not > "211"
			move wae-n169-n211-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-n169-n211-tots.

	ce005-payment-1.
		if wad-code = "272"
			if wad-code-n = "0"
				move wae-ssp-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-ssp-totals
			end-if
			if wad-code-n = "1" or "2"
				move wae-smp-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-smp-totals
			end-if
			if wad-code-n = "3" or "7"
				move wae-sap-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-sap-totals
			end-if
			if wad-code-n = "4" or "8"
				move wae-spp-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-spp-totals
			end-if
			if wad-code-n = "6" or "9"
				move wae-aspp-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-aspp-totals
			end-if
			if wad-code-n = "5"
				move wae-ftc-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-ftc-totals.
		if wad-code not < "242" and not > "265"
			move wae-non-tax-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-non-tax-totals.
		go to ce999-exit.

	ce010-deduction.
		if waa-special-prt = zero
			go to ce010-deduction-1.
		if wad-code not < "324" and not > "363"
			move wae-n325-n363-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-n325-n363-tots.
		if wad-code not < "430" and not > "519"
			move wae-n431-n519-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-n431-n519-tots.
		if wad-code not < "520" and not > "533"
			move wae-n521-n533-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-n521-n533-tots.

	ce010-deduction-1.
		move wae-ded-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-ded-totals.
		if wad-shuffle-code = "9200"
			move wae-comc1-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-comc1-totals.
		if wad-shuffle-code = "9201"
			move wae-comc2-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-comc2-totals.
		if wad-shuffle-code = "9202"
			move wae-comc3-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-comc3-totals.
		if wad-shuffle-code = "9205"
			move wae-comc1A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-comc1A-totals.
		if wad-shuffle-code = "9206"
			move wae-comc2A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-comc2A-totals.
		if wad-shuffle-code = "9207"
			move wae-comc3A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-comc3A-totals.
		if wad-shuffle-code = "9220"
			move wae-pri1-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-pri1-totals.
		if wad-shuffle-code = "9240"
			move wae-cod1-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod1-totals.
		if wad-shuffle-code = "9245"
			move wae-cod1A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod1A-totals.
		if wad-shuffle-code = "9241"
			move wae-cod2-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod2-totals.
		if wad-shuffle-code = "9246"
			move wae-cod2A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod2A-totals.
		if wad-shuffle-code = "9242"
			move wae-cod3-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod3-totals.
		if wad-shuffle-code = "9247"
			move wae-cod3A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod3A-totals.
		if wad-shuffle-code = "9243"
			move wae-cod4-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod4-totals.
		if wad-shuffle-code = "9248"
			move wae-cod4A-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-cod4A-totals.
		if wad-shuffle-code = "9124"
			if fbb-link-ind = "L"
				move wae-sl-totals to wag-data-num2	
				perform zx-add-subtract
				move wag-data-num2 to wae-sl-totals.
		if (wad-code = "910" or "912")
			if fbb-link-ind not = "L"
				move wae-aeos-totals to wag-data-num2
				perform zx-add-subtract
				move wag-data-num2 to wae-aeos-totals.
		if wad-code = "928"
			move wae-debt-totals to wag-data-num2	
			perform zx-add-subtract
			move wag-data-num2 to wae-debt-totals.
		if wad-code = "946"
			move wae-round-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-round-totals.
		go to ce999-exit.

	ce015-tax.
		if wad-code = "850"
			move wae-p45-taxable to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p45-taxable.
		if wad-code = "852"
			move wae-tax-taxable to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tax-taxable.
		if wad-code = "854"
			move wae-p45-tax to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p45-tax.
		if wad-code = "856"
			move wae-tax-tax to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tax-tax.
		go to ce999-exit.

	ce020-ni.
		if wad-shuffle-code = "7040" or "7140" or "7240"
				   or "7340" or "7440" or "7540"
				   or "7640" or "7740" or "7840"
				   or "8040"
			move wae-eesni-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-eesni-totals.
		if wad-shuffle-code = "7303" or "7603"
		    if waa-use-nicalc5-mkr = zero
			move wae-eesni-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-eesni-totals.
		if wad-shuffle-code = "7060" or "7160" or "7260"
				   or "7360" or "7460" or "7560"
				   or "7660" or "7760" or "7860"
				   or "8060"
			move wae-ersni-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-totals.
		if wad-shuffle-code = "7363" or "7463" or "7563"
				   or "7663" or "7763" or "7863"
				   or "7920"
      * Ni employers rebate
		    if waa-use-nicalc5-mkr = zero
			move wae-ersni-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-totals.
      *	CAT A total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7040"
			move wae-ees-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-a-totals.
		if wad-shuffle-code = "7049"
			move wae-niable-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-a-totals
			move wae-touel-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-a-totals.
		if wad-shuffle-code = "7043"
			move wae-tolel-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-a-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-a-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-a-totals
			else
			move wae-niable-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-a-totals.
		if wad-shuffle-code = "7045"
			move wae-toet-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-a-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-a-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-a-totals
			else
			move wae-niable-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-a-totals.
		if wad-shuffle-code = "7025"
			move wae-touap-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-a-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-a-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-a-totals
			else
                move wae-niable-a-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-a-totals
		    end-if
	    end-if.
		if wad-shuffle-code = "7005"
			move wae-uelplus-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-a-totals.
		if wad-shuffle-code = "7060"
			move wae-ersni-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-a-totals.

      *	CAT B total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, EUL+, ERs NI ...
		if wad-shuffle-code = "7140"
			move wae-ees-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-b-totals.
		if wad-shuffle-code = "7149"
			move wae-niable-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-b-totals
			move wae-touel-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-b-totals.
		if wad-shuffle-code = "7143"
			move wae-tolel-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-b-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-b-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-b-totals
			else
			move wae-niable-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-b-totals.
		if wad-shuffle-code = "7145"
			move wae-toet-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-b-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-b-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-b-totals
			else
			move wae-niable-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-b-totals.
		if wad-shuffle-code = "7125"
			move wae-touap-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-b-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-b-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-b-totals
			else
                move wae-niable-b-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-b-totals
			end-if
        end-if.
		if wad-shuffle-code = "7105"
			move wae-uelplus-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-b-totals.
		if wad-shuffle-code = "7160"
			move wae-ersni-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-b-totals.

      *	CAT C total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7249"
			move wae-niable-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-c-totals
			move wae-touel-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-c-totals.
		if wad-shuffle-code = "7243"
			move wae-tolel-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-c-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-c-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-c-totals
			else
			move wae-niable-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-c-totals.
		if wad-shuffle-code = "7245"
			move wae-toet-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-c-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-c-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-c-totals
			else
			move wae-niable-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-c-totals.
		if wad-shuffle-code = "7225"
			move wae-touap-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-c-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-c-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-c-totals
			else
                move wae-niable-c-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-c-totals
			end-if
        end-if.
		if wad-shuffle-code = "7205"
			move wae-uelplus-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-c-totals.
		if wad-shuffle-code = "7260"
			move wae-ersni-c-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-c-totals.

      *	CAT D total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7340"
			move wae-ees-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-d-totals.
		if wad-shuffle-code = "7349"
			move wae-niable-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-d-totals
			move wae-touel-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-d-totals.
		if wad-shuffle-code = "7343"
			move wae-tolel-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-d-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-d-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-d-totals
			else
			move wae-niable-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-d-totals.
		if wad-shuffle-code = "7345"
			move wae-toet-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-d-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-d-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-d-totals
			else
			move wae-niable-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-d-totals.
		if wad-shuffle-code = "7325"
			move wae-touap-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-d-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-d-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-d-totals
			else
                move wae-niable-d-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-d-totals
			end-if
        end-if.
		if wad-shuffle-code = "7305"
			move wae-uelplus-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-d-totals.
		if wad-shuffle-code = "7360"
			move wae-ersni-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-d-totals.
		if wad-shuffle-code = "7303"
		     if waa-use-nicalc5-mkr = zero
			move wae-eesreb-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-eesreb-d-totals.
		if wad-shuffle-code = "7363"
		     if waa-use-nicalc5-mkr = zero
			move wae-ersreb-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersreb-d-totals.

      *	CAT E total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7440"
			move wae-ees-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-e-totals.
		if wad-shuffle-code = "7449"
			move wae-niable-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-e-totals
			move wae-touel-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-e-totals.
		if wad-shuffle-code = "7443"
			move wae-tolel-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-e-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-e-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-e-totals
			else
			move wae-niable-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-e-totals.
		if wad-shuffle-code = "7445"
			move wae-toet-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-e-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-e-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-e-totals
			else
			move wae-niable-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-e-totals.
		if wad-shuffle-code = "7425"
			move wae-touap-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-e-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-e-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-e-totals
			else
                move wae-niable-e-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-e-totals
			end-if
        end-if.
		if wad-shuffle-code = "7405"
			move wae-uelplus-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-e-totals.
		if wad-shuffle-code = "7460"
			move wae-ersni-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-e-totals.
		if wad-shuffle-code = "7463"
		     if waa-use-nicalc5-mkr = zero
			move wae-ersreb-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersreb-e-totals.

      *	CAT L total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7540"
			move wae-ees-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-l-totals.
		if wad-shuffle-code = "7549"
			move wae-niable-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-l-totals
			move wae-touel-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-l-totals.
		if wad-shuffle-code = "7543"
			move wae-tolel-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-l-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-l-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-l-totals
			else
			move wae-niable-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-l-totals.
		if wad-shuffle-code = "7545"
			move wae-toet-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-l-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-l-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-l-totals
			else
			move wae-niable-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-l-totals.
		if wad-shuffle-code = "7525"
			move wae-touap-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-l-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-l-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-l-totals
			else
                move wae-niable-l-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-l-totals
			end-if
        end-if.
		if wad-shuffle-code = "7505"
			move wae-uelplus-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-l-totals.
		if wad-shuffle-code = "7560"
			move wae-ersni-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-l-totals.
		if wad-shuffle-code = "7563"
		     if waa-use-nicalc5-mkr = zero
			move wae-ersreb-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersreb-l-totals.

      *	CAT F total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7640"
			move wae-ees-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-f-totals.
		if wad-shuffle-code = "7649"
			move wae-niable-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-f-totals
			move wae-touel-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-f-totals.
		if wad-shuffle-code = "7643"
			move wae-tolel-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-f-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-f-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-f-totals
			else
			move wae-niable-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-f-totals.
		if wad-shuffle-code = "7645"
			move wae-toet-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-f-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-f-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-f-totals
			move wag-data-num2 to wae-toet-f-totals
			move wae-niable-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-f-totals.
		if wad-shuffle-code = "7625"
			move wae-touap-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-f-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-f-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-f-totals
			else
                move wae-niable-f-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-f-totals
			end-if
        end-if.
		if wad-shuffle-code = "7605"
			move wae-uelplus-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-f-totals.
		if wad-shuffle-code = "7660"
			move wae-ersni-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-f-totals.
		if wad-shuffle-code = "7603"
		     if waa-use-nicalc5-mkr = zero
			move wae-eesreb-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-eesreb-f-totals.
		if wad-shuffle-code = "7663"
		     if waa-use-nicalc5-mkr = zero
			move wae-ersreb-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersreb-f-totals.

      *	CAT G total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7740"
			move wae-ees-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-g-totals.
		if wad-shuffle-code = "7749"
			move wae-niable-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-g-totals
			move wae-touel-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-g-totals.
		if wad-shuffle-code = "7743"
			move wae-tolel-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-g-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-g-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-g-totals
			else
			move wae-niable-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-g-totals.
		if wad-shuffle-code = "7745"
			move wae-toet-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-g-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-g-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-g-totals
			else
			move wae-niable-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-g-totals.
		if wad-shuffle-code = "7725"
			move wae-touap-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-g-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-g-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-g-totals
			else
                move wae-niable-g-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-g-totals
			end-if
        end-if.
		if wad-shuffle-code = "7705"
			move wae-uelplus-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-g-totals.
		if wad-shuffle-code = "7760"
			move wae-ersni-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-g-totals.
		if wad-shuffle-code = "7763"
		     if waa-use-nicalc5-mkr = zero
			move wae-ersreb-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersreb-g-totals.

      *	CAT S total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "7840"
			move wae-ees-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-s-totals.
		if wad-shuffle-code = "7849"
			move wae-niable-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-s-totals
			move wae-touel-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-s-totals.
		if wad-shuffle-code = "7843"
			move wae-tolel-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-s-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-s-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-s-totals
			else
			move wae-niable-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-s-totals.
		if wad-shuffle-code = "7845"
			move wae-toet-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-s-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-s-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-s-totals
			else
			move wae-niable-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-s-totals.
		if wad-shuffle-code = "7825"
			move wae-touap-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-s-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-s-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-s-totals
			else
                move wae-niable-s-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-s-totals
			end-if
        end-if.
		if wad-shuffle-code = "7805"
			move wae-uelplus-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-s-totals.
		if wad-shuffle-code = "7860"
			move wae-ersni-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-s-totals.
		if wad-shuffle-code = "7863"
		     if waa-use-nicalc5-mkr = zero
			move wae-ersreb-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersreb-s-totals.

      *	CAT J total:- EEs NI, NIable, ToLEL, ToPT, ToUEL, UEL+, ERs NI ...
		if wad-shuffle-code = "8040"
			move wae-ees-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ees-j-totals.
		if wad-shuffle-code = "8049"
			move wae-niable-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-j-totals
			move wae-touel-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-j-totals.
		if wad-shuffle-code = "8043"
			move wae-tolel-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-tolel-j-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-j-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-j-totals
			else
			move wae-niable-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-j-totals.
		if wad-shuffle-code = "8045"
			move wae-toet-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-toet-j-totals
		     if waa-use-nicalc5-mkr = zero
			move wae-touel-j-totals to wag-data-num2
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-touel-j-totals
			else
			move wae-niable-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-niable-j-totals.
		if wad-shuffle-code = "8025"
			move wae-touap-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-touap-j-totals
		    if waa-use-nicalc5-mkr = zero
				move wae-touel-j-totals to wag-data-num2
				move 1 to waa-add-sub-flag
				perform zx-add-subtract
				move wag-data-num2 to wae-touel-j-totals
			else
                move wae-niable-j-totals to wag-data-num2
				perform zx-add-subtract
                move wag-data-num2 to wae-niable-j-totals
			end-if
        end-if.
		if wad-shuffle-code = "8005"
			move wae-uelplus-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-uelplus-j-totals.
		if wad-shuffle-code = "8060"
			move wae-ersni-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-j-totals.

		if wad-shuffle-code = "7920"
			move wae-ersni-p-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-ersni-p-totals.
		go to ce999-exit.

	ce025-dss.
		if wad-shuffle-code = "2701"
			move wae-smpi-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-smpi-totals.
		if wad-shuffle-code = "2707"
			move wae-sapi-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-sapi-totals.
		if wad-shuffle-code = "2708"
			move wae-sppi-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-sppi-totals.
		if wad-shuffle-code = "2709"
			move wae-asppi-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-asppi-totals.
		if wad-shuffle-code = "7940"
			move wae-smp-rec-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-smp-rec-totals.
		if wad-shuffle-code = "7943"
			move wae-sap-rec-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-sap-rec-totals.
		if wad-shuffle-code = "7944"
			move wae-spp-rec-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-spp-rec-totals.
		if wad-shuffle-code = "7946"
			move wae-aspp-rec-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-aspp-rec-totals.
		go to ce999-exit.

	ce035-3rd-party.
		if wad-code not < "280" and not > "299"
			move wae-3rd-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-3rd-totals
			perform di-include-3rd.
		go to ce999-exit.

	ce040-net-pay-calc.
		move wae-mits-net to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-mits-net.
		move fbb-employee to fab-employee.
		if waa-code-break = zero
			move wad-save-dept to fab-dept
			move wad-save-sub to fab-sub-dept
			else
			move wad-fbb-dept to fab-dept
			move wad-sub-dept-new to fab-sub-dept.
      *		if fab-key not = wad-fbb-key
			read fa-employee-header
				invalid key
				go to ce999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if fab-bank-code = spaces
			move zero to fab-bank-code.
      *		if wae-result = zero and wad-code = "948"
		if wae-result = zero
			go to ce999-exit.
		if wad-code = "948"
			add 1 to wab-net-paid
			move fab-ni-class to waf-sex
			if waf-gender = "M"
				add 1 to wab-male-paid
				else
				add 1 to wab-female-paid.
		perform dl-how-paid.
		go to ce999-exit.

	ce045-calc-notions.
		move 1 to waa-notion-flag waa-d-notion-flag
			waa-p-notion-flag.
		if wad-shuffle-code = "7980"
			move wae-notion-ssp-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-notion-ssp-totals.
		if wad-shuffle-code = "7982"
			move wae-notion-smp-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-notion-smp-totals.
		if wad-shuffle-code = "7983"
			move wae-notion-sap-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-notion-sap-totals.
		if wad-shuffle-code = "7984"
			move wae-notion-spp-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-notion-spp-totals.
		if wad-shuffle-code = "7985"
			move wae-notion-aspp-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-notion-aspp-totals.


	ce999-exit.
		exit.

      **| STATE S3.11 |**************************************************
      *  CF-SAVE-PAY-DED.						*
      *    This section saves the descriptions and data of data codes	*
      *    relating to payments, deductions, pension and 3rd parties.	*
      *    The file produced, is used as a 'hold' file for printing	*
      *    the SUB-DEPT data.						*
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	cf-save-pay-ded						section.

	cf000-start.
		if wab-code-type not = 9
			if wad-code < "050" or > "699"
				go to cf999-exit.
		if wad-code = "272"
			go to cf999-exit.
		if wad-shuffle-code = "2701" or "2984"
				or "2707" or "2708"
			go to cf999-exit.
		perform yk-gloss-desc.
		move "A" to fa-rec-type.
		if wad-code not < "050" and not > "279"
			go to cf020-test.
		if wad-code not < "550" and not > "659"
			go to cf020-test.
		move "P" to fa-rec-type.
		if wad-code not < "300" and not > "363"
			go to cf020-test.
		move "3" to fa-rec-type.
		if wad-code not < "280" and not > "299"
			go to cf020-test.
		move "N" to fa-rec-type.
		if wad-code not < "364" and not > "383"
			go to cf020-test.
		if wad-code not < "416" and not > "429"
			go to cf020-test.
		if wad-code not < "538" and not > "549"
			go to cf020-test.
		if wad-code not < "660" and not > "699"
			go to cf020-test.
		if wad-code not < "798" and not > "799"
			go to cf020-test.
		move space to fa-rec-type.

	cf020-test.
		if wag-data-num1 = zero
			go to cf999-exit.
		move wad-shuffle-code to fa-key.
		read fa-pay-fl invalid key
			move wag-data-num1 to fa-data
			write fa-pay-record
			go to cf999-exit.
		move fa-data to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to fa-data.
		rewrite fa-pay-record.

	cf999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	cg-tran-new						section.

	cg000-start.
		move wad-fbb-key to fab-key.
		move fab-key to ftr-key.
		move zero to waa-tran-new.
	
	cg005-read.
		read fa-employee-header
			invalid key
			go to cg999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	cg020-transfer-search.
		read ft-tran-fl
			invalid key
			go to cg999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move 1 to waa-tran-new.

	cg999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ch-read-fe-or-fb					section.

	ch000-start.
		if waa-code-break = zero
			go to ch010-read-fb.
		move fea-sort-key to waa-tag-key.

	ch005-start-fe.
		if waa-emp-change = zero
			go to ch010-read-fb.
		move zero to waa-tran-new.
		read fe-tag-file next record
			at end
			move 1 to waa-eof-flag
			move 2 to waa-cost-break
			go to ch999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fea-key to wad-split-cost.
		if wab-read-mkr not = zero
			if (wad-save-cost not = wad-cost-str
				and waa-cost-break < 1)
				move 1 to waa-cost-break
			end-if
			if (wad-cost-dept not = wad-save-dept
				and waa-cost-break < 2)
				move 2 to waa-cost-break.
		move wad-cost-str to wad-save-cost.
		move fea-tag-key to
			fbb-key
			wad-save-new-key
			wad-fbb-key.
		move zero to waa-emp-change.
		start fb-employee-variables key not < fbb-key
			invalid key
			move 1 to waa-emp-change
			go to ch005-start-fe.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		perform cg-tran-new.

	ch010-read-fb.
		move fbb-key to waa-last-key.
		read fb-employee-variables next record
			at end
			move all "_" to fba-key
			if waa-code-break = zero
				move 1 to waa-eof-flag
				move zero to waa-tran-new
				go to ch999-exit.
		if waa-code-break = zero
			if fbb-key not = waa-last-key
				move zero to waa-tran-new.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fbb-key to wad-fbb-key.
		if waa-special-split not = zero
      *			and waa-scan = zero
				move wad-cost-dept to fbb-dept.
		if waa-code-break not = zero
			if fbb-employee not = fea-employee
				or fbb-dept not = wad-cost-dept
					move 1 to waa-emp-change
					go to ch005-start-fe.

	ch999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ci-update-fe-trans					section.

	ci000-start.
		open i-o fj-transfers.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	ci005-read.
		read fj-transfers next record
			at end
			close fj-transfers
			go to ci999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		perform dk-update-fe.
		go to ci005-read.

	ci999-exit.
		close fe-tag-file.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open input fe-tag-file.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move all "_" to fea-rec.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	cj-create-tag						section.

	cj000-start.
		move zero to faa-key.
		read fa-employee-header
			invalid key
			display "P? O shit ".
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open output fe-tag-file.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	cj100-read.
		read fa-employee-header next record
			at end
			go to cj900-close.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if fab-key = zero
			go to cj100-read.
		move spaces to fea-rec.
		move spaces to waa-tag-key.
		move fab-key to fea-tag-key.
		move fab-employee to fea-employee.
		if waa-scan = zero
			move fab-cost-code to waa-tk-cost-code
			perform dm-set-tk-dept
			else
			move fab-dept to waa-tk-dept.
		move fab-employee to waa-tk-employee.
		move fab-sub-dept to waa-tk-sub-dept.

	cj110-rewrite.
		move waa-tag-key to fea-sort-key.
		write fea-rec.
		if wzz-io-err-code not = zero
			move zero to wzz-io-err-code
			if waa-tk-ctx numeric
				add 1 to waa-tk-ct
				else
				move 1 to waa-tk-ct
			end-if
			go to cj110-rewrite.
		go to cj100-read.

	cj900-close.
		move zero to faa-key.
		read fa-employee-header
			invalid key
			display "P? O shit ".
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fe-tag-file.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		
	cj999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	da-write-dept-file					section.

	da000-start.
		move low-values to fa-key.
		start fa-pay-fl key not < fa-key invalid key
			go to da025-beginning.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	da005-read-sub.
		move zero to wag-data-numbers.
		read fa-pay-fl next record
			at end
			go to da025-beginning.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	da010-read-dept-file.
		move fa-key to fb-key.
		read fb-pay-fl
			invalid key
			go to da020-write-record.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	da015-dept-found.
		move fb-data to wag-data-num1.
		move fa-data to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to fb-data.
		rewrite fb-pay-record.
		go to da005-read-sub.

	da020-write-record.
		move fa-pay-record to fb-pay-record.
		write fb-pay-record.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		go to da005-read-sub.

	da025-beginning.
		move low-values to fa-key.
		start fa-pay-fl key not < fa-key invalid key
			go to da999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	da999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	db-upd-dept-totes					section.

	db000-start.
		if waa-special-prt not = zero
		      move wae-n81-n123-tots to wag-data-num1
		      move wae-d-n81-n123-tots to wag-data-num2
		      perform zx-add-subtract
		      move wag-data-num2 to wae-d-n81-n123-tots
		      move wae-n125-n167-tots to wag-data-num1
		      move wae-d-n125-n167-tots to wag-data-num2
		      perform zx-add-subtract
		      move wag-data-num2 to wae-d-n125-n167-tots
		      move wae-n169-n211-tots to wag-data-num1
		      move wae-d-n169-n211-tots to wag-data-num2
		      perform zx-add-subtract
		      move wag-data-num2 to wae-d-n169-n211-tots
		      move wae-n325-n363-tots to wag-data-num1
		      move wae-d-n325-n363-tots to wag-data-num2
		      perform zx-add-subtract
		      move wag-data-num2 to wae-d-n325-n363-tots
		      move wae-n431-n519-tots to wag-data-num1
		      move wae-d-n431-n519-tots to wag-data-num2
		      perform zx-add-subtract
		      move wag-data-num2 to wae-d-n431-n519-tots
		      move wae-n521-n533-tots to wag-data-num1
		      move wae-d-n521-n533-tots to wag-data-num2
		      perform zx-add-subtract
		      move wag-data-num2 to wae-d-n521-n533-tots.
		move wae-non-tax-totals to wag-data-num1.
		move wae-d-non-tax-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-non-tax-totals.
		move wae-ftc-totals to wag-data-num1.
		move wae-d-ftc-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ftc-totals.
		move wae-gross-totals to wag-data-num1.
		move wae-d-gross-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-gross-totals.
		move wae-3rd-not-inc to wag-data-num1.
		move wae-d-3rd-not-inc to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-3rd-not-inc.
		move wae-mits-net to wag-data-num1.
		move wae-d-mits-net to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-mits-net.
		move wae-ded-totals to wag-data-num1.
		move wae-d-ded-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ded-totals.
		move wae-ssp-totals to wag-data-num1.
		move wae-d-ssp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ssp-totals.
		move wae-smpi-totals to wag-data-num1.
		move wae-d-smpi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-smpi-totals.
		move wae-sapi-totals to wag-data-num1.
		move wae-d-sapi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-sapi-totals.

		move wae-sppi-totals to wag-data-num1.
		move wae-d-sppi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-sppi-totals.

		move wae-asppi-totals to wag-data-num1.
		move wae-d-asppi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-asppi-totals.

		move wae-smp-totals to wag-data-num1.
		move wae-d-smp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-smp-totals.

		move wae-sap-totals to wag-data-num1.
		move wae-d-sap-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-sap-totals.

		move wae-spp-totals to wag-data-num1.
		move wae-d-spp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-spp-totals.

		move wae-aspp-totals to wag-data-num1.
		move wae-d-aspp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-aspp-totals.

		move wae-ssp-rec-totals to wag-data-num1.
		move wae-d-ssp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ssp-rec-totals.
		move wae-smp-com-totals to wag-data-num1.
		move wae-d-smp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-smp-com-totals.
		move wae-sap-com-totals to wag-data-num1.
		move wae-d-sap-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-sap-com-totals.
		move wae-spp-com-totals to wag-data-num1.
		move wae-d-spp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-spp-com-totals.
		move wae-aspp-com-totals to wag-data-num1.
		move wae-d-aspp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-aspp-com-totals.
		move wae-smp-rec-totals to wag-data-num1.
		move wae-d-smp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-smp-rec-totals.
		move wae-sap-rec-totals to wag-data-num1.
		move wae-d-sap-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-sap-rec-totals.
		move wae-spp-rec-totals to wag-data-num1.
		move wae-d-spp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-spp-rec-totals.
		move wae-aspp-rec-totals to wag-data-num1.
		move wae-d-aspp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-aspp-rec-totals.
		move wae-debt-totals to wag-data-num1.
		move wae-d-debt-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-debt-totals.
		move wae-3rd-totals to wag-data-num1.
		move wae-d-3rd-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-3rd-totals.
		move wae-round-totals to wag-data-num1.
		move wae-d-round-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-round-totals.
		move wae-nitot-totals to wag-data-num1.
		move wae-d-nitot-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-nitot-totals.

		move wae-niable-a-totals to wag-data-num1.
		move wae-d-niable-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-a-totals.
		move wae-tolel-a-totals to wag-data-num1.
		move wae-d-tolel-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-a-totals.
		move wae-toet-a-totals to wag-data-num1.
		move wae-d-toet-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-a-totals.
		move wae-touap-a-totals to wag-data-num1.
		move wae-d-touap-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-a-totals.
		move wae-touel-a-totals to wag-data-num1.
		move wae-d-touel-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-a-totals.
		move wae-uelplus-a-totals to wag-data-num1.
		move wae-d-uelplus-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-a-totals.

		move wae-niable-b-totals to wag-data-num1.
		move wae-d-niable-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-b-totals.
		move wae-tolel-b-totals to wag-data-num1.
		move wae-d-tolel-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-b-totals.
		move wae-toet-b-totals to wag-data-num1.
		move wae-d-toet-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-b-totals.
		move wae-touap-b-totals to wag-data-num1.
		move wae-d-touap-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-b-totals.
		move wae-touel-b-totals to wag-data-num1.
		move wae-d-touel-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-b-totals.
		move wae-uelplus-b-totals to wag-data-num1.
		move wae-d-uelplus-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-b-totals.

		move wae-niable-c-totals to wag-data-num1.
		move wae-d-niable-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-c-totals.
		move wae-tolel-c-totals to wag-data-num1.
		move wae-d-tolel-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-c-totals.
		move wae-toet-c-totals to wag-data-num1.
		move wae-d-toet-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-c-totals.
		move wae-touap-c-totals to wag-data-num1.
		move wae-d-touap-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-c-totals.
		move wae-touel-c-totals to wag-data-num1.
		move wae-d-touel-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-c-totals.
		move wae-uelplus-c-totals to wag-data-num1.
		move wae-d-uelplus-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-c-totals.

		move wae-niable-d-totals to wag-data-num1.
		move wae-d-niable-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-d-totals.
		move wae-tolel-d-totals to wag-data-num1.
		move wae-d-tolel-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-d-totals.
		move wae-toet-d-totals to wag-data-num1.
		move wae-d-toet-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-d-totals.
		move wae-touap-d-totals to wag-data-num1.
		move wae-d-touap-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-d-totals.
		move wae-touel-d-totals to wag-data-num1.
		move wae-d-touel-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-d-totals.
		move wae-uelplus-d-totals to wag-data-num1.
		move wae-d-uelplus-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-d-totals.

		move wae-niable-e-totals to wag-data-num1.
		move wae-d-niable-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-e-totals.
		move wae-tolel-e-totals to wag-data-num1.
		move wae-d-tolel-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-e-totals.
		move wae-toet-e-totals to wag-data-num1.
		move wae-d-toet-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-e-totals.
		move wae-touap-e-totals to wag-data-num1.
		move wae-d-touap-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-e-totals.
		move wae-touel-e-totals to wag-data-num1.
		move wae-d-touel-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-e-totals.
		move wae-uelplus-e-totals to wag-data-num1.
		move wae-d-uelplus-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-e-totals.

		move wae-niable-l-totals to wag-data-num1.
		move wae-d-niable-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-l-totals.
		move wae-tolel-l-totals to wag-data-num1.
		move wae-d-tolel-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-l-totals.
		move wae-toet-l-totals to wag-data-num1.
		move wae-d-toet-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-l-totals.
		move wae-touap-l-totals to wag-data-num1.
		move wae-d-touap-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-l-totals.
		move wae-touel-l-totals to wag-data-num1.
		move wae-d-touel-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-l-totals.
		move wae-uelplus-l-totals to wag-data-num1.
		move wae-d-uelplus-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-l-totals.

		move wae-niable-f-totals to wag-data-num1.
		move wae-d-niable-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-f-totals.
		move wae-tolel-f-totals to wag-data-num1.
		move wae-d-tolel-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-f-totals.
		move wae-toet-f-totals to wag-data-num1.
		move wae-d-toet-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-f-totals.
		move wae-touap-f-totals to wag-data-num1.
		move wae-d-touap-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-f-totals.
		move wae-touel-f-totals to wag-data-num1.
		move wae-d-touel-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-f-totals.
		move wae-uelplus-f-totals to wag-data-num1.
		move wae-d-uelplus-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-f-totals.

		move wae-niable-g-totals to wag-data-num1.
		move wae-d-niable-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-g-totals.
		move wae-tolel-g-totals to wag-data-num1.
		move wae-d-tolel-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-g-totals.
		move wae-toet-g-totals to wag-data-num1.
		move wae-d-toet-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-g-totals.
		move wae-touap-g-totals to wag-data-num1.
		move wae-d-touap-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-g-totals.
		move wae-touel-g-totals to wag-data-num1.
		move wae-d-touel-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-g-totals.
		move wae-uelplus-g-totals to wag-data-num1.
		move wae-d-uelplus-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-g-totals.

		move wae-niable-s-totals to wag-data-num1.
		move wae-d-niable-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-s-totals.
		move wae-tolel-s-totals to wag-data-num1.
		move wae-d-tolel-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-s-totals.
		move wae-toet-s-totals to wag-data-num1.
		move wae-d-toet-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-s-totals.
		move wae-touap-s-totals to wag-data-num1.
		move wae-d-touap-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-s-totals.
		move wae-touel-s-totals to wag-data-num1.
		move wae-d-touel-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-s-totals.
		move wae-uelplus-s-totals to wag-data-num1.
		move wae-d-uelplus-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-s-totals.

		move wae-niable-j-totals to wag-data-num1.
		move wae-d-niable-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-niable-j-totals.
		move wae-tolel-j-totals to wag-data-num1.
		move wae-d-tolel-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tolel-j-totals.
		move wae-toet-j-totals to wag-data-num1.
		move wae-d-toet-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-toet-j-totals.
		move wae-touap-j-totals to wag-data-num1.
		move wae-d-touap-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touap-j-totals.
		move wae-touel-j-totals to wag-data-num1.
		move wae-d-touel-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-touel-j-totals.
		move wae-uelplus-j-totals to wag-data-num1.
		move wae-d-uelplus-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-uelplus-j-totals.

		move wae-eesni-totals to wag-data-num1.
		move wae-d-eesni-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-eesni-totals.

		move wae-tax-taxable to wag-data-num1.
		move wae-d-tax-taxable to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tax-taxable.

		move wae-tax-tax to wag-data-num1.
		move wae-d-tax-tax to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-tax-tax.

		move wae-p45-tax to wag-data-num1.
		move wae-d-p45-tax to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-p45-tax.

		move wae-p45-taxable to wag-data-num1.
		move wae-d-p45-taxable to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-p45-taxable.

		move wae-comc1-totals to wag-data-num1.
		move wae-d-comc1-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-comc1-totals.
		move wae-comc1A-totals to wag-data-num1.
		move wae-d-comc1A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-comc1A-totals.
		move wae-comc2-totals to wag-data-num1.
		move wae-d-comc2-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-comc2-totals.
		move wae-comc2A-totals to wag-data-num1.
		move wae-d-comc2A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-comc2A-totals.
		move wae-comc3-totals to wag-data-num1.
		move wae-d-comc3-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-comc3-totals.
		move wae-comc3A-totals to wag-data-num1.
		move wae-d-comc3A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-comc3A-totals.
		move wae-cod1-totals to wag-data-num1.
		move wae-d-cod1-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod1-totals.
		move wae-cod1A-totals to wag-data-num1.
		move wae-d-cod1A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod1A-totals.
		move wae-cod2-totals to wag-data-num1.
		move wae-d-cod2-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod2-totals.
		move wae-cod2A-totals to wag-data-num1.
		move wae-d-cod2A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod2A-totals.
		move wae-cod3-totals to wag-data-num1.
		move wae-d-cod3-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod3-totals.
		move wae-cod3A-totals to wag-data-num1.
		move wae-d-cod3A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod3A-totals.
		move wae-cod4-totals to wag-data-num1.
		move wae-d-cod4-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod4-totals.
		move wae-cod4A-totals to wag-data-num1.
		move wae-d-cod4A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-cod4A-totals.
		move wae-aeos-totals to wag-data-num1.
		move wae-d-aeos-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-aeos-totals.
		move wae-sl-totals to wag-data-num1.
		move wae-d-sl-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-sl-totals.
		move wae-pri1-totals to wag-data-num1.
		move wae-d-pri1-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-pri1-totals.

		move wae-ersni-totals to wag-data-num1.
		move wae-d-ersni-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-totals.

		move wae-ees-a-totals to wag-data-num1.
		move wae-d-ees-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-a-totals.

		move wae-ees-b-totals to wag-data-num1.
		move wae-d-ees-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-b-totals.

		move wae-ees-c-totals to wag-data-num1.
		move wae-d-ees-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-c-totals.

		move wae-ees-d-totals to wag-data-num1.
		move wae-d-ees-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-d-totals.

		move wae-ees-e-totals to wag-data-num1.
		move wae-d-ees-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-e-totals.

		move wae-ees-l-totals to wag-data-num1.
		move wae-d-ees-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-l-totals.

		move wae-ees-f-totals to wag-data-num1.
		move wae-d-ees-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-f-totals.

		move wae-ees-g-totals to wag-data-num1.
		move wae-d-ees-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-g-totals.

		move wae-ees-s-totals to wag-data-num1.
		move wae-d-ees-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-s-totals.

		move wae-ees-j-totals to wag-data-num1.
		move wae-d-ees-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ees-j-totals.

		move wae-ersni-a-totals to wag-data-num1.
		move wae-d-ersni-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-a-totals.

		move wae-ersni-b-totals to wag-data-num1.
		move wae-d-ersni-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-b-totals.

		move wae-ersni-c-totals to wag-data-num1.
		move wae-d-ersni-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-c-totals.

		move wae-ersni-d-totals to wag-data-num1.
		move wae-d-ersni-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-d-totals.

		move wae-ersni-e-totals to wag-data-num1.
		move wae-d-ersni-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-e-totals.

		move wae-ersni-l-totals to wag-data-num1.
		move wae-d-ersni-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-l-totals.

		move wae-ersni-f-totals to wag-data-num1.
		move wae-d-ersni-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-f-totals.

		move wae-ersni-g-totals to wag-data-num1.
		move wae-d-ersni-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-g-totals.

		move wae-ersni-s-totals to wag-data-num1.
		move wae-d-ersni-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-s-totals.

		move wae-ersni-j-totals to wag-data-num1.
		move wae-d-ersni-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-j-totals.

		move wae-ersni-p-totals to wag-data-num1.
		move wae-d-ersni-p-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersni-p-totals.

		move wae-notion-ssp-totals to wag-data-num1.
		move wae-d-notion-ssp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-notion-ssp-totals.
		move wae-notion-smp-totals to wag-data-num1.
		move wae-d-notion-smp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-notion-smp-totals.
		move wae-notion-sap-totals to wag-data-num1.
		move wae-d-notion-sap-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-notion-sap-totals.
		move wae-notion-spp-totals to wag-data-num1.
		move wae-d-notion-spp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-notion-spp-totals.
		move wae-notion-aspp-totals to wag-data-num1.
		move wae-d-notion-aspp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-notion-aspp-totals.

		if waa-use-nicalc5-mkr not = zero
			go to db010-methods.
		move wae-ersreb-d-totals to wag-data-num1.
		move wae-d-ersreb-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersreb-d-totals.
		move wae-ersreb-e-totals to wag-data-num1.
		move wae-d-ersreb-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersreb-e-totals.
		move wae-ersreb-l-totals to wag-data-num1.
		move wae-d-ersreb-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersreb-l-totals.
		move wae-ersreb-f-totals to wag-data-num1.
		move wae-d-ersreb-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersreb-f-totals.
		move wae-ersreb-g-totals to wag-data-num1.
		move wae-d-ersreb-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersreb-g-totals.
		move wae-ersreb-s-totals to wag-data-num1.
		move wae-d-ersreb-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-ersreb-s-totals.
		move wae-eesreb-d-totals to wag-data-num1.
		move wae-d-eesreb-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-eesreb-d-totals.
		move wae-eesreb-f-totals to wag-data-num1.
		move wae-d-eesreb-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-d-eesreb-f-totals.

	db010-methods.
		add wab-male-cnt to wab-d-male-cnt.
		add wab-female-cnt to wab-d-female-cnt.
		add wab-male-paid to
			wab-d-male-paid
			wab-p-male-paid.
		add wab-net-paid to
			wab-d-net-paid
			wab-p-net-paid.
		add wab-female-paid to
			wab-d-female-paid
			wab-p-female-paid.
		add wab-male-not-paid to
			wab-d-male-not-paid
			wab-p-male-not-paid.
		add wab-female-not-paid to
			wab-d-female-not-paid
			wab-p-female-not-paid.
		add wab-male-left-cnt to wab-d-male-left-cnt.
		add wab-female-left-cnt to wab-d-female-left-cnt.
		add wab-bank-cnt to wab-d-bank-cnt wab-p-bank-cnt.
		add wab-other-cnt to wab-d-other-cnt wab-p-other-cnt.
		add wab-cash-cnt to wab-d-cash-cnt wab-p-cash-cnt.
		add wab-bank-amt to wab-d-bank-amt wab-p-bank-amt.
		add wab-other-amt to wab-d-other-amt wab-p-other-amt.
		add wab-cash-amt to wab-d-cash-amt wab-p-cash-amt.
		perform varying wab-gen-cnt from 1 by 1
					until wab-gen-cnt > 11
			add wac-csh-cnts(wab-gen-cnt) to
				wac-d-csh-var(wab-gen-cnt)
		end-perform.

	db999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dc-clear-sub-file					section.

	dc000-start.
		move zero to
			wae-ave-totals
			wae-gross-totals
			wae-ssp-totals
			wae-smp-totals
			wae-sap-totals
			wae-spp-totals
			wae-aspp-totals
			wae-smpi-totals
			wae-sapi-totals
			wae-sppi-totals
			wae-asppi-totals
			wae-ded-totals
			wae-debt-totals
			wae-n81-n123-tots
			wae-n125-n167-tots
			wae-n169-n211-tots
			wae-n325-n363-tots
			wae-n431-n519-tots
			wae-n521-n533-tots
			wae-round-totals
			wae-comc1-totals
			wae-comc1A-totals
			wae-comc2A-totals
			wae-comc3A-totals
			wae-aeos-totals
			wae-sl-totals
			wae-comc2-totals
			wae-comc3-totals
			wae-cod1-totals
			wae-cod2-totals
			wae-cod1A-totals
			wae-cod2A-totals
			wae-cod3-totals
			wae-cod4-totals
			wae-cod3A-totals
			wae-cod4A-totals
			wae-eesni-totals
			wae-taxed-totals
			wae-niables-totals
			wae-ees-totals
			wae-ersni-totals
			wae-ers-totals
			wae-dss-totals
			wab-methods
			wae-3rd-totals
			wac-cash-amt
			wac-other-amt
			wac-bank-amt
			wae-notion-ssp-totals
			wae-notion-smp-totals
			wae-notion-sap-totals
			wae-notion-spp-totals
			wae-notion-aspp-totals
			wae-ssp-rec-totals
			wae-smp-com-totals
			wae-sap-com-totals
			wae-spp-com-totals
			wae-aspp-com-totals
			waa-notion-flag
			wal-coin-analysis
			wac-cash-vars
			wae-mits-net
			wae-non-tax-totals
			wae-ftc-totals
			wae-3rd-not-inc
			wae-pri1-totals
			wae-smp-rec-totals
			wae-sap-rec-totals
			wae-spp-rec-totals
			wae-aspp-rec-totals.
		close fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open output fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o fa-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	dc999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dd-code-type						section.

	dd000-start.
		move 1 to wab-code-type.				pays
		if wad-code not < "050" and not > "269"
			go to dd999-exit.
		if wad-code not < "550" and not > "659"
			go to dd999-exit.
		if wad-shuffle-code = "2720" or "2721"
				   or "2722" or "2725"
				   or "2723" or "2724"
				   or "2727" or "2728"
                   or "2726" or "2729"
			go to dd999-exit.
		move 2 to wab-code-type.				deds
		if wad-code not < "300" and not > "363"
			go to dd999-exit.
		if wad-code not < "384" and not > "415"
			go to dd999-exit.
		if wad-code not < "430" and not > "537"
			go to dd999-exit.
		if wad-code not < "910" and not > "913"
			go to dd999-exit.
		if wad-code not < "920" and not > "925"
			go to dd999-exit.
		if wad-code = "928" or "946"
			go to dd999-exit.
		move 3 to wab-code-type.				tax
		if wad-code not < "850" and not > "856"
			go to dd999-exit.
		move 4 to wab-code-type.				N.I.
		if wad-code not < "700" and not > "793"
			go to dd999-exit.
		if wad-code not < "800" and not > "809"
			go to dd999-exit.
		move 5 to wab-code-type.				DSS
		if wad-shuffle-code = "2701" or "7940"
				   or "2707" or "2708"
				   or "7943" or "7944" or "7946"
			go to dd999-exit.
		move 7 to wab-code-type.				3rd pty
		if wad-code not < "280" and not > "299"
			go to dd999-exit.
		move 8 to wab-code-type.				net
		if wad-code = "948" or "940"
			go to dd999-exit.
		move 9 to wab-code-type.				notl
		if wad-code not < "274" and not > "279"
			go to dd999-exit.
		if wad-code not < "364" and not > "383"
			go to dd999-exit.
		if wad-code not < "416" and not > "429"
			go to dd999-exit.
		if wad-code not < "538" and not > "549"
			go to dd999-exit.
		if wad-code not < "660" and not > "699"
			go to dd999-exit.
		if wad-code not < "798" and not > "799"
			go to dd999-exit.
		move zero to wab-code-type.

	dd999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	df-write-payroll-file					section.

	df000-start.
		move low-values to fb-key.
		start fb-pay-fl key not < fb-key invalid key
			go to df025-beginning.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	df005-read-sub.
		move zero to wag-data-numbers.
		read fb-pay-fl next record
			at end
			go to df025-beginning.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	df010-read-dept-file.
		move fb-key to fc-key.
		read fc-pay-fl
			invalid key
			go to df020-write-record.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	df015-dept-found.
		move fc-data to wag-data-num1.
		move fb-data to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to fc-data.
		rewrite fc-pay-record.
		go to df005-read-sub.

	df020-write-record.
		move fb-pay-record to fc-pay-record.
		write fc-pay-record.
		go to df005-read-sub.

	df025-beginning.
		move low-values to fa-key.
		start fb-pay-fl key not < fb-key invalid key
			go to df999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	df999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dg-upd-payroll-totes					section.

	dg000-start.
		if waa-special-prt not = zero
			move wae-d-n81-n123-tots to wag-data-num1
			move wae-p-n81-n123-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-n81-n123-tots
			move wae-d-n125-n167-tots to wag-data-num1
			move wae-p-n125-n167-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-n125-n167-tots
			move wae-d-n169-n211-tots to wag-data-num1
			move wae-p-n169-n211-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-n169-n211-tots
			move wae-d-n325-n363-tots to wag-data-num1
			move wae-p-n325-n363-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-n325-n363-tots
			move wae-d-n431-n519-tots to wag-data-num1
			move wae-p-n431-n519-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-n431-n519-tots
			move wae-d-n521-n533-tots to wag-data-num1
			move wae-p-n521-n533-tots to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-n521-n533-tots.
		move wae-d-non-tax-totals to wag-data-num1.
		move wae-p-non-tax-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-non-tax-totals.
		move wae-d-ftc-totals to wag-data-num1.
		move wae-p-ftc-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ftc-totals.
		move wae-d-gross-totals to wag-data-num1.
		move wae-p-gross-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-gross-totals.
		move wae-d-3rd-not-inc to wag-data-num1.
		move wae-p-3rd-not-inc to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-3rd-not-inc.
		move wae-d-mits-net to wag-data-num1.
		move wae-p-mits-net to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-mits-net.
		move wae-d-ded-totals to wag-data-num1.
		move wae-p-ded-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ded-totals.
		move wae-d-ssp-totals to wag-data-num1.
		move wae-p-ssp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ssp-totals.
		move wae-d-smpi-totals to wag-data-num1.
		move wae-p-smpi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-smpi-totals.
		move wae-d-sapi-totals to wag-data-num1.
		move wae-p-sapi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-sapi-totals.

		move wae-d-sppi-totals to wag-data-num1.
		move wae-p-sppi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-sppi-totals.

		move wae-d-asppi-totals to wag-data-num1.
		move wae-p-asppi-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-asppi-totals.

		move wae-d-smp-totals to wag-data-num1.
		move wae-p-smp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-smp-totals.
		move wae-d-sap-totals to wag-data-num1.
		move wae-p-sap-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-sap-totals.

		move wae-d-spp-totals to wag-data-num1.
		move wae-p-spp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-spp-totals.

		move wae-d-aspp-totals to wag-data-num1.
		move wae-p-aspp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-aspp-totals.

		move wae-d-ssp-rec-totals to wag-data-num1.
		move wae-p-ssp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ssp-rec-totals.
		move wae-d-notion-ssp-totals to wag-data-num1.
		move wae-p-notion-ssp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-notion-ssp-totals.
		move wae-d-notion-smp-totals to wag-data-num1.
		move wae-p-notion-smp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-notion-smp-totals.
		move wae-d-notion-sap-totals to wag-data-num1.
		move wae-p-notion-sap-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-notion-sap-totals.
		move wae-d-notion-spp-totals to wag-data-num1.
		move wae-p-notion-spp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-notion-spp-totals.
		move wae-d-notion-aspp-totals to wag-data-num1.
		move wae-p-notion-aspp-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-notion-aspp-totals.
		move wae-d-3rd-totals to wag-data-num1.
		move wae-p-3rd-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-3rd-totals.
		move wae-d-smp-com-totals to wag-data-num1.
		move wae-p-smp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-smp-com-totals.
		move wae-d-sap-com-totals to wag-data-num1.
		move wae-p-sap-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-sap-com-totals.
		move wae-d-spp-com-totals to wag-data-num1.
		move wae-p-spp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-spp-com-totals.
		move wae-d-aspp-com-totals to wag-data-num1.
		move wae-p-aspp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-aspp-com-totals.
		move wae-d-smp-rec-totals to wag-data-num1.
		move wae-p-smp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-smp-rec-totals.
		move wae-d-sap-rec-totals to wag-data-num1.
		move wae-p-sap-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-sap-rec-totals.
		move wae-d-spp-rec-totals to wag-data-num1.
		move wae-p-spp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-spp-rec-totals.
		move wae-d-aspp-rec-totals to wag-data-num1.
		move wae-p-aspp-rec-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-aspp-rec-totals.
		move wae-d-debt-totals to wag-data-num1.
		move wae-p-debt-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-debt-totals.
		move wae-d-round-totals to wag-data-num1.
		move wae-p-round-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-round-totals.
		move wae-d-nitot-totals to wag-data-num1.
		move wae-p-nitot-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-nitot-totals.

		move wae-d-niable-a-totals to wag-data-num1.
		move wae-p-niable-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-a-totals.
		move wae-d-tolel-a-totals to wag-data-num1.
		move wae-p-tolel-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-a-totals.
		move wae-d-toet-a-totals to wag-data-num1.
		move wae-p-toet-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-a-totals.
		move wae-d-touap-a-totals to wag-data-num1.
		move wae-p-touap-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-a-totals.
		move wae-d-touel-a-totals to wag-data-num1.
		move wae-p-touel-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-a-totals.
		move wae-d-uelplus-a-totals to wag-data-num1.
		move wae-p-uelplus-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-a-totals.

		move wae-d-niable-b-totals to wag-data-num1.
		move wae-p-niable-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-b-totals.
		move wae-d-tolel-b-totals to wag-data-num1.
		move wae-p-tolel-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-b-totals.
		move wae-d-toet-b-totals to wag-data-num1.
		move wae-p-toet-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-b-totals.
		move wae-d-touap-b-totals to wag-data-num1.
		move wae-p-touap-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-b-totals.
		move wae-d-touel-b-totals to wag-data-num1.
		move wae-p-touel-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-b-totals.
		move wae-d-uelplus-b-totals to wag-data-num1.
		move wae-p-uelplus-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-b-totals.

		move wae-d-niable-c-totals to wag-data-num1.
		move wae-p-niable-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-c-totals.
		move wae-d-tolel-c-totals to wag-data-num1.
		move wae-p-tolel-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-c-totals.
		move wae-d-toet-c-totals to wag-data-num1.
		move wae-p-toet-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-c-totals.
		move wae-d-touap-c-totals to wag-data-num1.
		move wae-p-touap-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-c-totals.
		move wae-d-touel-c-totals to wag-data-num1.
		move wae-p-touel-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-c-totals.
		move wae-d-uelplus-c-totals to wag-data-num1.
		move wae-p-uelplus-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-c-totals.

		move wae-d-niable-d-totals to wag-data-num1.
		move wae-p-niable-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-d-totals.
		move wae-d-tolel-d-totals to wag-data-num1.
		move wae-p-tolel-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-d-totals.
		move wae-d-toet-d-totals to wag-data-num1.
		move wae-p-toet-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-d-totals.
		move wae-d-touap-d-totals to wag-data-num1.
		move wae-p-touap-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-d-totals.
		move wae-d-touel-d-totals to wag-data-num1.
		move wae-p-touel-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-d-totals.
		move wae-d-uelplus-d-totals to wag-data-num1.
		move wae-p-uelplus-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-d-totals.

		move wae-d-niable-e-totals to wag-data-num1.
		move wae-p-niable-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-e-totals.
		move wae-d-tolel-e-totals to wag-data-num1.
		move wae-p-tolel-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-e-totals.
		move wae-d-toet-e-totals to wag-data-num1.
		move wae-p-toet-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-e-totals.
		move wae-d-touap-e-totals to wag-data-num1.
		move wae-p-touap-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-e-totals.
		move wae-d-touel-e-totals to wag-data-num1.
		move wae-p-touel-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-e-totals.
		move wae-d-uelplus-e-totals to wag-data-num1.
		move wae-p-uelplus-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-e-totals.

		move wae-d-niable-l-totals to wag-data-num1.
		move wae-p-niable-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-l-totals.
		move wae-d-tolel-l-totals to wag-data-num1.
		move wae-p-tolel-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-l-totals.
		move wae-d-toet-l-totals to wag-data-num1.
		move wae-p-toet-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-l-totals.
		move wae-d-touap-l-totals to wag-data-num1.
		move wae-p-touap-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-l-totals.
		move wae-d-touel-l-totals to wag-data-num1.
		move wae-p-touel-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-l-totals.
		move wae-d-uelplus-l-totals to wag-data-num1.
		move wae-p-uelplus-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-l-totals.

		move wae-d-niable-f-totals to wag-data-num1.
		move wae-p-niable-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-f-totals.
		move wae-d-tolel-f-totals to wag-data-num1.
		move wae-p-tolel-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-f-totals.
		move wae-d-toet-f-totals to wag-data-num1.
		move wae-p-toet-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-f-totals.
		move wae-d-touap-f-totals to wag-data-num1.
		move wae-p-touap-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-f-totals.
		move wae-d-touel-f-totals to wag-data-num1.
		move wae-p-touel-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-f-totals.
		move wae-d-uelplus-f-totals to wag-data-num1.
		move wae-p-uelplus-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-f-totals.

		move wae-d-niable-g-totals to wag-data-num1.
		move wae-p-niable-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-g-totals.
		move wae-d-tolel-g-totals to wag-data-num1.
		move wae-p-tolel-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-g-totals.
		move wae-d-toet-g-totals to wag-data-num1.
		move wae-p-toet-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-g-totals.
		move wae-d-touap-g-totals to wag-data-num1.
		move wae-p-touap-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-g-totals.
		move wae-d-touel-g-totals to wag-data-num1.
		move wae-p-touel-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-g-totals.
		move wae-d-uelplus-g-totals to wag-data-num1.
		move wae-p-uelplus-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-g-totals.

		move wae-d-niable-s-totals to wag-data-num1.
		move wae-p-niable-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-s-totals.
		move wae-d-tolel-s-totals to wag-data-num1.
		move wae-p-tolel-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-s-totals.
		move wae-d-toet-s-totals to wag-data-num1.
		move wae-p-toet-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-s-totals.
		move wae-d-touap-s-totals to wag-data-num1.
		move wae-p-touap-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-s-totals.
		move wae-d-touel-s-totals to wag-data-num1.
		move wae-p-touel-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-s-totals.
		move wae-d-uelplus-s-totals to wag-data-num1.
		move wae-p-uelplus-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-s-totals.

		move wae-d-niable-j-totals to wag-data-num1.
		move wae-p-niable-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-niable-j-totals.
		move wae-d-tolel-j-totals to wag-data-num1.
		move wae-p-tolel-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tolel-j-totals.
		move wae-d-toet-j-totals to wag-data-num1.
		move wae-p-toet-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-toet-j-totals.
		move wae-d-touap-j-totals to wag-data-num1.
		move wae-p-touap-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touap-j-totals.
		move wae-d-touel-j-totals to wag-data-num1.
		move wae-p-touel-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-touel-j-totals.
		move wae-d-uelplus-j-totals to wag-data-num1.
		move wae-p-uelplus-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-uelplus-j-totals.

		move wae-d-eesni-totals to wag-data-num1.
		move wae-p-eesni-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-eesni-totals.

		move wae-tax-taxable to wag-data-num1.
		move wae-tax-taxable to wag-data-num1.
		move wae-d-tax-taxable to wag-data-num1.
		move wae-p-tax-taxable to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tax-taxable.
		move wae-d-tax-tax to wag-data-num1.
		move wae-p-tax-tax to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-tax-tax.
		move wae-d-p45-tax to wag-data-num1.
		move wae-p-p45-tax to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-p45-tax.
		move wae-d-p45-taxable to wag-data-num1.
		move wae-p-p45-taxable to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-p45-taxable.

		move wae-d-comc1-totals to wag-data-num1.
		move wae-p-comc1-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-comc1-totals.
		move wae-d-comc1A-totals to wag-data-num1.
		move wae-p-comc1A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-comc1A-totals.
		move wae-d-comc2-totals to wag-data-num1.
		move wae-p-comc2-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-comc2-totals.
		move wae-d-comc2A-totals to wag-data-num1.
		move wae-p-comc2A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-comc2A-totals.
		move wae-d-comc3-totals to wag-data-num1.
		move wae-p-comc3-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-comc3-totals.
		move wae-d-comc3A-totals to wag-data-num1.
		move wae-p-comc3A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-comc3A-totals.
		move wae-d-cod1-totals to wag-data-num1.
		move wae-p-cod1-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod1-totals.
		move wae-d-cod1A-totals to wag-data-num1.
		move wae-p-cod1A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod1A-totals.
		move wae-d-cod2-totals to wag-data-num1.
		move wae-p-cod2-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod2-totals.
		move wae-d-cod2A-totals to wag-data-num1.
		move wae-p-cod2A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod2A-totals.
		move wae-d-cod3-totals to wag-data-num1.
		move wae-p-cod3-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod3-totals.
		move wae-d-cod3A-totals to wag-data-num1.
		move wae-p-cod3A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod3A-totals.
		move wae-d-cod4-totals to wag-data-num1.
		move wae-p-cod4-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod4-totals.
		move wae-d-cod4A-totals to wag-data-num1.
		move wae-p-cod4A-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-cod4A-totals.
		move wae-d-aeos-totals to wag-data-num1.
		move wae-p-aeos-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-aeos-totals.
		move wae-d-sl-totals to wag-data-num1.
		move wae-p-sl-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-sl-totals.
		move wae-d-pri1-totals to wag-data-num1.
		move wae-p-pri1-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-pri1-totals.

		move wae-d-ersni-totals to wag-data-num1.
		move wae-p-ersni-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-totals.

		move wae-d-ees-a-totals to wag-data-num1.
		move wae-p-ees-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-a-totals.

		move wae-d-ees-b-totals to wag-data-num1.
		move wae-p-ees-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-b-totals.

		move wae-d-ees-c-totals to wag-data-num1.
		move wae-p-ees-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-c-totals.

		move wae-d-ees-d-totals to wag-data-num1.
		move wae-p-ees-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-d-totals.

		move wae-d-ees-e-totals to wag-data-num1.
		move wae-p-ees-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-e-totals.

		move wae-d-ees-l-totals to wag-data-num1.
		move wae-p-ees-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-l-totals.

		move wae-d-ees-f-totals to wag-data-num1.
		move wae-p-ees-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-f-totals.

		move wae-d-ees-g-totals to wag-data-num1.
		move wae-p-ees-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-g-totals.

		move wae-d-ees-s-totals to wag-data-num1.
		move wae-p-ees-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-s-totals.

		move wae-d-ees-j-totals to wag-data-num1.
		move wae-p-ees-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ees-j-totals.

		move wae-d-ersni-a-totals to wag-data-num1.
		move wae-p-ersni-a-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-a-totals.

		move wae-d-ersni-b-totals to wag-data-num1.
		move wae-p-ersni-b-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-b-totals.

		move wae-d-ersni-c-totals to wag-data-num1.
		move wae-p-ersni-c-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-c-totals.

		move wae-d-ersni-d-totals to wag-data-num1.
		move wae-p-ersni-d-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-d-totals.

		move wae-d-ersni-e-totals to wag-data-num1.
		move wae-p-ersni-e-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-e-totals.

		move wae-d-ersni-l-totals to wag-data-num1.
		move wae-p-ersni-l-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-l-totals.

		move wae-d-ersni-f-totals to wag-data-num1.
		move wae-p-ersni-f-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-f-totals.

		move wae-d-ersni-g-totals to wag-data-num1.
		move wae-p-ersni-g-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-g-totals.

		move wae-d-ersni-s-totals to wag-data-num1.
		move wae-p-ersni-s-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-s-totals.

		move wae-d-ersni-j-totals to wag-data-num1.
		move wae-p-ersni-j-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-j-totals.

		move wae-d-ersni-p-totals to wag-data-num1.
		move wae-p-ersni-p-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-p-ersni-p-totals.

		if waa-use-nicalc5-mkr = zero
			move wae-d-ersreb-d-totals to wag-data-num1
			move wae-p-ersreb-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-ersreb-d-totals
			move wae-d-ersreb-e-totals to wag-data-num1
			move wae-p-ersreb-e-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-ersreb-e-totals
			move wae-d-ersreb-l-totals to wag-data-num1
			move wae-p-ersreb-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-ersreb-l-totals
			move wae-d-ersreb-f-totals to wag-data-num1
			move wae-p-ersreb-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-ersreb-f-totals
			move wae-d-ersreb-g-totals to wag-data-num1
			move wae-p-ersreb-g-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-ersreb-g-totals
			move wae-d-ersreb-s-totals to wag-data-num1
			move wae-p-ersreb-s-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-ersreb-s-totals
			move wae-d-eesreb-d-totals to wag-data-num1
			move wae-p-eesreb-d-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-eesreb-d-totals
			move wae-d-eesreb-f-totals to wag-data-num1
			move wae-p-eesreb-f-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-p-eesreb-f-totals.

		perform varying wab-gen-cnt from 1 by 1
					until wab-gen-cnt > 11
			add wac-d-csh-var(wab-gen-cnt) to
				wac-p-csh-var(wab-gen-cnt)
		end-perform.

	dg999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dh-clear-dept-file					section.

	dh000-start.
		move zero to
			wae-ave-totals
			wae-d-gross-totals
			wae-d-n81-n123-tots
			wae-d-n125-n167-tots
			wae-d-n169-n211-tots
			wae-d-n325-n363-tots
			wae-d-n431-n519-tots
			wae-d-n521-n533-tots
			wae-d-ssp-totals
			wae-d-smp-totals
			wae-d-sap-totals
			wae-d-spp-totals
			wae-d-aspp-totals
			wae-d-smpi-totals
			wae-d-sapi-totals
			wae-d-sppi-totals
			wae-d-asppi-totals
			wae-d-ded-totals
			wae-d-debt-totals
			wae-d-round-totals
			wae-d-comc1-totals
			wae-d-comc1A-totals
			wae-d-comc2-totals
			wae-d-comc3-totals
			wae-d-comc2A-totals
			wae-d-comc3A-totals
			wae-d-cod1-totals
			wae-d-cod2-totals
			wae-d-cod3-totals
			wae-d-cod2A-totals
			wae-d-cod3A-totals
			wae-d-cod1A-totals
			wae-d-cod4A-totals
		 	wae-d-cod4-totals
			wae-d-eesni-totals
			wae-taxed-dept-totals
			wae-niable-depts
			wae-ees-dept-totals
			wae-ersni-dept-totals
			wae-d-ersni-totals
			wae-d-3rd-not-inc
			wae-d-non-tax-totals
			wae-d-ftc-totals
			wae-d-aeos-totals
			wae-d-sl-totals
			wae-d-pri1-totals
			wae-d-pri1-totals
			wae-ave-totals
			wae-gross-totals
			wae-ssp-totals
			wae-smp-totals
			wae-sap-totals
			wae-spp-totals
			wae-aspp-totals
			wae-ftc-totals
			wae-aeos-totals
			wae-pri1-totals
			wae-smpi-totals
			wae-sapi-totals
			wae-sppi-totals
			wae-asppi-totals
			wae-ded-totals
			wae-debt-totals
			wae-round-totals
			wae-comc1-totals
			wae-comc2-totals
			wae-comc3-totals
			wae-comc2A-totals
			wae-comc3A-totals
			wae-cod1-totals
			wae-cod2-totals
			wae-cod1A-totals
			wae-cod2A-totals
			wae-cod3-totals
			wae-cod4-totals
			wae-cod3A-totals
			wae-cod4A-totals
			wae-eesni-totals
			wae-taxed-totals
			wae-niables-totals
			wae-ees-totals
			wae-ersni-totals
			wae-ers-totals
			wae-dss-totals
			wab-methods
			wab-dept-methods
			wae-d-notion-ssp-totals
			wae-d-notion-smp-totals
			wae-d-notion-sap-totals
			wae-d-notion-spp-totals
			wae-d-notion-aspp-totals
			wae-d-smp-com-totals
			wae-d-sap-com-totals
			wae-d-spp-com-totals
			wae-d-aspp-com-totals
			wae-d-ssp-rec-totals
			wae-d-smp-rec-totals
			wae-d-sap-rec-totals
			wae-d-spp-rec-totals
			wae-d-aspp-rec-totals
			waa-d-notion-flag
			wae-d-3rd-totals
			wae-3rd-totals
			wac-d-cash-vars
			wac-cash-vars
			wae-d-mits-net
			wae-mits-net
			wae-3rd-not-inc
			wae-non-tax-totals
			wae-n81-n123-tots
			wae-n125-n167-tots
			wae-n169-n211-tots
			wae-n325-n363-tots
			wae-n431-n519-tots
			wae-n521-n533-tots
			wae-comc1A-totals
			wae-sl-totals.
		close fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open output fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		close fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		open i-o fb-pay-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	dh999-exit.
		exit.

      *******************************************************************
      * Check for 3rd Party inclusion.
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	di-include-3rd						section.

	di000-start.
		move waf-fv-run-date to fvb-date.
		string wad-code-n wad-code delimited
			by size into fvb-data-code.

	di005-read-fv-file.
		read fv-variables-glossary
			invalid key
			go to di999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	di010-test-flag.
		if fvb-deduction-option not = "&"
			go to di999-exit.

	di015-accumulate.
		move wae-3rd-not-inc to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-3rd-not-inc.

	di999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dj-calc-columns						section.

	dj000-start.
		if waa-tran-new not = zero
			move zero to fbb-todate-adjust.
		move fbb-todate-adjust to wag-num1-col(3).
		if wad-code = "928" or "946"
			subtract fbb-todate from zero
				giving fbb-todate
			subtract fbb-prev-todate from zero
				giving fbb-prev-todate
			subtract fbb-off-manual from zero
				giving fbb-off-manual
			subtract fbb-off-reversal from zero
				giving fbb-off-reversal
			subtract fbb-prev-todate from fbb-todate
				giving wae-result
		else
			if fbb-reset-mkr = space
				subtract fbb-prev-todate from
					fbb-todate giving wae-result
			else
				move fbb-todate to wae-result.
		add fbb-todate to wag-num1-col(6).
		move wae-result to wag-num1-col(4).
		add wae-result to fbb-off-manual
			giving wag-num1-col(5).
		subtract fbb-off-reversal from wag-num1-col(5).
		if fbb-todate-adjust not = zero
			and waa-tran-new = zero
			subtract fbb-todate-adjust from
				fbb-prev-todate.
		subtract fbb-off-reversal from fbb-off-manual.
		if fbb-off-manual not = zero
			subtract fbb-off-manual from fbb-prev-todate.
		if waa-tran-new = zero
			move fbb-prev-todate to wag-num1-col(1)
		else
			move fbb-prev-todate to wag-num1-col(3).
		move fbb-off-manual to wag-num1-col(2).
		if fbb-reset-mkr not = space
			subtract wag-num1-col(1) from zero
				giving wag-num1-col(3)
			subtract wag-num1-col(2) from wag-num1-col(3).

	dj999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dk-update-fe						section.

	dk000-start.
		move zero to waa-cost-found.
		move fja-transfer-emp to wad-split-fja-key.
		open i-o fze-cc-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	dk005-search.
		read fze-cc-fl next record
			at end
			go to dk010-test-find.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if fze-emp-ref not = fja-transfer-emp
			go to dk005-search.
		move 1 to waa-cost-found.
		move fze-old-cost-code to wad-work-cost.

	dk010-test-find.
		close fze-cc-fl.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		if waa-cost-found not = zero
			go to dk020-write-record.
		move fja-transfer-to-ref to fab-key.
		read fa-employee-header
			invalid key
			go to dk999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fab-cost-code to wad-work-cost.

	dk020-write-record.
		move spaces to fea-rec.
		if waa-special-split = zero
      *			or waa-scan not = zero
			string	wad-fja-dept
				wad-work-cost
				wad-fja-emp
				wad-fja-sub-dept
					delimited by size
					into fea-key
			else
			move wad-work-cost to waa-tk-cost-code
			perform dm-set-tk-dept
			string	waa-tk-dept
				waa-tk-cost-code
				wad-fja-emp
				wad-fja-sub-dept
					delimited by size
					into fea-key.
		move fja-transfer-emp to fea-tag-key.
		move wad-fja-emp to fea-employee.

	dk110-rewrite.
		write fea-rec.
		if wzz-io-err-code not = zero
			move zero to wzz-io-err-code
			if feb-ctx numeric
				add 1 to feb-ct
				else
				move 1 to feb-ct
			end-if
			go to dk110-rewrite.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	dk999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dl-how-paid						section.

	dl000-start.
		if fab-paid-other
			add 1 to wab-other-cnt
			add wae-result to wab-other-amt.
		if fab-paid-cash
			add 1 to wab-cash-cnt
			add wae-result to wab-cash-amt
			perform yl-cash-anal.
		if fab-paid-bacs
			or fab-paid-giro
			or fab-paid-bacs-bacs
				add wae-result to wab-bank-amt
				add 1 to wab-bank-cnt.
		if fab-paid-bacs-cash or fab-paid-giro-cash
			if wad-code = "940"
				add wae-result to wab-bank-amt
				add 1 to wab-bank-cnt
			end-if
			if wad-code = "948"
				add 1 to wab-cash-cnt
				add wae-result to wab-cash-amt
				perform yl-cash-anal.

	dl999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	dm-set-tk-dept						section.

	dm000-start.
		move fub-extra-opts(9) to waa-1c.
		perform varying wab-cnt from 1 by 1
						until wab-cnt > waa-1n
			move waa-tk-cc-char(wab-cnt) to
				waa-tk-dept-char(wab-cnt)
		end-perform.

	dm999-exit.
		exit.

      *******************************************************************
      * YA-PAY-PRT.							*
      *   This section, prints the PAYMENTS section of the print.	*
      *   SSP PAID and SMP PAID are included.				*
      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ya-pay-prt						section.

	ya000-start.
		move 1 to
			waa-grp1-prted
			waa-grp2-prted
			waa-grp3-prted.
		if waa-print-flag = 2
			move wae-d-n81-n123-tots to wae-n81-n123-tots
			move wae-d-n125-n167-tots to wae-n125-n167-tots
			move wae-d-n169-n211-tots to wae-n169-n211-tots.
		if waa-print-flag = 3
			move wae-p-n81-n123-tots to wae-n81-n123-tots
			move wae-p-n125-n167-tots to wae-n125-n167-tots
			move wae-p-n169-n211-tots to wae-n169-n211-tots.
		move low-values to fa-key fb-key fc-key.
		if waa-print-flag = 1
			start fa-pay-fl key not < fa-key invalid key
				go to ya999-exit.
		if waa-print-flag = 2
			move wae-d-gross-totals to wae-gross-totals
			start fb-pay-fl key not < fb-key invalid key
				go to ya999-exit.
		if waa-print-flag = 3
			move wae-p-gross-totals to wae-gross-totals
			start fc-pay-fl key not < fc-key invalid key
				go to ya999-exit.
		if wae-gross-totals = zero
			go to ya999-exit.
		move "PAYMENTS:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to waa-prt-eof.
		perform za-print-line.
		move "PAYMENTS CONTINUED...." to waf-current-alpha.

	ya005-files-to-use.
		go to
			ya015-sub-dept-file
			ya020-dept-file
			ya010-payroll-file
				depending on waa-print-flag.
		go to ya999-exit.

	ya010-payroll-file.
		read fc-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fc-pay-rec to waf-pay-rec waf-pay-rec-save.
		go to ya025-end-pay-fls.

	ya015-sub-dept-file.
		read fa-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fa-pay-rec to waf-pay-rec waf-pay-rec-save.
		go to ya025-end-pay-fls.

	ya020-dept-file.
		read fb-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fb-pay-rec to waf-pay-rec waf-pay-rec-save.

	ya025-end-pay-fls.
		if waa-special-prt = zero
			if waa-prt-eof not = zero
				go to ya035-ssp-paid
			end-if
		else
			if waa-prt-eof not = zero
				go to ya030-test-record.
		if waf-rec-type not = "A"
			go to ya005-files-to-use.

	ya030-test-record.
		move 1 to waa-fmt-flag.
		if waa-special-prt = zero
			go to ya033-prt-spec.
		move waf-pay-ded to waf-spec-code.
		if (((waf-spec-val > "123") and (waa-grp1-prted = 1))
		    or (waa-prt-eof not = zero and waa-grp1-prted = 1))
			move zero to waa-grp1-prted
			move wae-n81-n123-tots to waf-data
			perform zb-format-line
			if waa-fmt-flag = zero
				string " **** SUB G N080 - N123 "
					waf-fmt-line delimited by size
						into waf-print-line
					go to ya033-prt-spec.
		if (((waf-spec-val > "167") and (waa-grp2-prted = 1))
		    or (waa-prt-eof not = zero and waa-grp2-prted = 1))
			move zero to waa-grp2-prted
			move wae-n125-n167-tots to waf-data
			perform zb-format-line
			if waa-fmt-flag = zero
				string " **** SUB G N124 - N167 "
					waf-fmt-line delimited by size
						into waf-print-line
					go to ya033-prt-spec.
		if (((waf-spec-val > "211") and (waa-grp3-prted = 1))
		    or (waa-prt-eof not = zero and waa-grp3-prted = 1))
			move zero to waa-grp3-prted
			move wae-n169-n211-tots to waf-data
			perform zb-format-line
			if waa-fmt-flag = zero
				string " **** SUB G N168 - N211 "
					waf-fmt-line delimited by size
						into waf-print-line.

	ya033-prt-spec.
		if waa-special-prt not = zero
			if waa-fmt-flag = zero
				perform za-print-line
			end-if
			if waa-prt-eof not = zero
				go to ya035-ssp-paid
			end-if
			move waf-pay-rec-save to waf-pay-rec.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya005-files-to-use.
		string waf-descrip waf-fmt-line delimited by size
			into waf-print-line.
		perform za-print-line.
		go to ya005-files-to-use.

	ya035-ssp-paid.
		if waa-print-flag = 2
			move wae-d-ssp-totals to wae-ssp-totals.
		if waa-print-flag = 3
			move wae-p-ssp-totals to wae-ssp-totals.
		move wae-ssp-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya037-smp-instalment.
		if waa-special-prt = zero
			string "      SSP PAID          " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0272 SSP PAID          " waf-fmt-line
				delimited by size into waf-print-line
		end-if.
		perform za-print-line.

	ya037-smp-instalment.
		if waa-print-flag = 2
			move wae-d-smpi-totals to wae-smpi-totals.
		if waa-print-flag = 3
			move wae-p-smpi-totals to wae-smpi-totals.
		move wae-smpi-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya040-smp-paid.
		if waa-special-prt = zero
			string "      SMP INSTALMENT    " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 1270 SMP INSTALMENT    " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya040-smp-paid.
		if waa-print-flag = 2
			move wae-d-smp-totals to wae-smp-totals.
		if waa-print-flag = 3
			move wae-p-smp-totals to wae-smp-totals.
		move wae-smp-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya042-sap-instalment.
		if waa-special-prt = zero
			string "      SMP PAID          " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 1272 SMP PAID          " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya042-sap-instalment.
		if waa-print-flag = 2
			move wae-d-sapi-totals to wae-sapi-totals.
		if waa-print-flag = 3
			move wae-p-sapi-totals to wae-sapi-totals.
		move wae-sapi-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya044-sap-paid.
		if waa-special-prt = zero
			string "      SAP INSTALMENT    " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 7270 SAP INSTALMENT    " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya044-sap-paid.
		if waa-print-flag = 2
			move wae-d-sap-totals to wae-sap-totals.
		if waa-print-flag = 3
			move wae-p-sap-totals to wae-sap-totals.
		move wae-sap-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya045-spp-instalment.
		if waa-special-prt = zero
			string "      SAP PAID          " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 3272 SAP PAID          " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya045-spp-instalment.
		if waa-print-flag = 2
			move wae-d-sppi-totals to wae-sppi-totals.
		if waa-print-flag = 3
			move wae-p-sppi-totals to wae-sppi-totals.
		move wae-sppi-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya046-spp-paid.
		if waa-special-prt = zero
			string "      OSPP INSTALMENT   " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 8270 OSPP INSTALMENT   " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya046-spp-paid.
		if waa-print-flag = 2
			move wae-d-spp-totals to wae-spp-totals.
		if waa-print-flag = 3
			move wae-p-spp-totals to wae-spp-totals.
		move wae-spp-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya047-aspp-instalment.
		if waa-special-prt = zero
			string "      OSPP PAID         " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 4272 OSPP PAID         " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya047-aspp-instalment.
		if waa-print-flag = 2
			move wae-d-asppi-totals to wae-asppi-totals.
		if waa-print-flag = 3
			move wae-p-asppi-totals to wae-asppi-totals.
		move wae-asppi-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya048-aspp-paid.
		if waa-special-prt = zero
			string "      ASPP INSTALMENT   " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 9270 ASPP INSTALMENT   " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya048-aspp-paid.
		if waa-print-flag = 2
			move wae-d-aspp-totals to wae-aspp-totals.
		if waa-print-flag = 3
			move wae-p-aspp-totals to wae-aspp-totals.
		move wae-aspp-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya050-ftc-paid.
		if waa-special-prt = zero
			string "      ASPP PAID         " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 6272 ASPP PAID         " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya050-ftc-paid.
		if waa-print-flag = 2
			move wae-d-ftc-totals to wae-ftc-totals.
		if waa-print-flag = 3
			move wae-p-ftc-totals to wae-ftc-totals.
		move wae-ftc-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ya090-gross-paid.
		if waa-special-prt = zero
			string "      TAX CREDITS       " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 5272 TAX CREDITS       " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ya090-gross-paid.
		move waf-underline to waf-print-line.
		perform za-print-line.
		move wae-gross-totals to waf-data.
		perform zb-format-line.
		string "   TOTAL: GROSS         " waf-fmt-line
			delimited by size into waf-print-line.
		perform za-print-line.

	ya095-ave-paid.
		move waf-data to wae-ave-totals.
		perform zc-ave-paid.
		move wae-ave-totals to waf-data.
		perform zb-format-line.
		string "   TOTAL: AVERAGE       " waf-fmt-line
			delimited by size into waf-print-line.
		perform za-print-line.

	ya990-reset.
		move spaces to waf-current-alpha.

	ya999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yb-ded-prt						section.

	yb000-start.
		move 1 to
			waa-grp4-prted
			waa-grp5-prted
			waa-grp6-prted.
		if waa-print-flag = 2
			move wae-d-n325-n363-tots to wae-n325-n363-tots
			move wae-d-n431-n519-tots to wae-n431-n519-tots
			move wae-d-n521-n533-tots to wae-n521-n533-tots
			move wae-d-aeos-totals to wae-aeos-totals
			move wae-d-sl-totals to wae-sl-totals
			move wae-d-pri1-totals to wae-pri1-totals.
		if waa-print-flag = 3
			move wae-p-n325-n363-tots to wae-n325-n363-tots
			move wae-p-n431-n519-tots to wae-n431-n519-tots
			move wae-p-n521-n533-tots to wae-n521-n533-tots
			move wae-p-aeos-totals to wae-aeos-totals
			move wae-p-sl-totals to wae-sl-totals
			move wae-p-pri1-totals to wae-pri1-totals.
		move low-values to fa-key fb-key fc-key.
		if waa-print-flag = 1
			start fa-pay-fl key not < fa-key invalid key
				go to yb999-exit.
		if waa-print-flag = 2
			start fb-pay-fl key not < fb-key invalid key
				go to yb999-exit.
		if waa-print-flag = 3
			start fc-pay-fl key not < fc-key invalid key
				go to yb999-exit.
		move "DEDUCTIONS:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to waa-prt-eof.
		perform za-print-line.
		move "DEDUCTIONS CONTINUED...." to waf-current-alpha.

	yb005-files-to-use.
		go to
			yb015-sub-dept-file
			yb020-dept-file
			yb010-payroll-file
				depending on waa-print-flag.
		go to yb999-exit.

	yb010-payroll-file.
		read fc-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fc-pay-rec to waf-pay-rec waf-pay-rec-save.
		go to yb025-end-pay-fls.

	yb015-sub-dept-file.
		read fa-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fa-pay-rec to waf-pay-rec waf-pay-rec-save.
		go to yb025-end-pay-fls.

	yb020-dept-file.
		read fb-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fb-pay-rec to waf-pay-rec waf-pay-rec-save.

	yb025-end-pay-fls.
		if waa-special-prt = zero
			if waa-prt-eof not = zero
				go to yb035-tax-paid
			end-if
		else
			if waa-prt-eof not = zero
				go to yb030-test-record.
		if waf-rec-type not = " " and not = "P"
			go to yb005-files-to-use.

	yb030-test-record.
		move 1 to waa-fmt-flag.
		if waa-special-prt = zero
			go to yb033-prt-spec.
		move waf-pay-ded to waf-spec-code.
		if (((waf-spec-val > "363") and (waa-grp4-prted = 1))
		    or (waa-prt-eof not = zero and waa-grp4-prted = 1))
			move zero to waa-grp4-prted
			move wae-n325-n363-tots to waf-data
			perform zb-format-line
			if waa-fmt-flag = zero
				string " **** SUB G N324 - N363 "
					waf-fmt-line delimited by size
						into waf-print-line
				go to yb033-prt-spec.
		if (((waf-spec-val > "519") and (waa-grp5-prted = 1))
		    or (waa-prt-eof not = zero and waa-grp5-prted = 1))
			move zero to waa-grp5-prted
			move wae-n431-n519-tots to waf-data
			perform zb-format-line
			if waa-fmt-flag = zero
				string " **** SUB G N430 - N519 "
					waf-fmt-line delimited by size
						into waf-print-line
				     go to yb033-prt-spec.
		if (((waf-spec-val > "533") and (waa-grp6-prted = 1))
		    or (waa-prt-eof not = zero and waa-grp6-prted = 1))
			move zero to waa-grp6-prted
			move wae-n521-n533-tots to waf-data
			perform zb-format-line
			if waa-fmt-flag = zero
				string " **** SUB G N520 - N533 "
					waf-fmt-line delimited by size
						into waf-print-line.

	yb033-prt-spec.
		if waa-special-prt not = zero
			if waa-fmt-flag = zero
				perform za-print-line
			end-if
			if waa-prt-eof not = zero
				go to yb035-tax-paid
			end-if
			move waf-pay-rec-save to waf-pay-rec.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb005-files-to-use.
		string waf-descrip waf-fmt-line delimited by size
			into waf-print-line.
		perform za-print-line
		go to yb005-files-to-use.

	yb035-tax-paid.
		move wae-tax-tax to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb040-ees-ni.
		if waa-special-prt = zero
			string "      TAX               " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0856 TAX               " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb040-ees-ni.
		move wae-eesni-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb050-aoe-dedn.
		if waa-special-prt = zero
			string "      NET EES NI        " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0704-0784 NET EES NI   " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb050-aoe-dedn.
		if waa-print-flag = 2
			move wae-d-comc1-totals to wae-comc1-totals
			move wae-d-comc2-totals to wae-comc2-totals
			move wae-d-comc3-totals to wae-comc3-totals
			move wae-d-comc1A-totals to wae-comc1A-totals
			move wae-d-comc2A-totals to wae-comc2A-totals
			move wae-d-comc3A-totals to wae-comc3A-totals
			move wae-d-cod1-totals to wae-cod1-totals
			move wae-d-cod2-totals to wae-cod2-totals
			move wae-d-cod3-totals to wae-cod3-totals
			move wae-d-cod4-totals to wae-cod4-totals
			move wae-d-cod1A-totals to wae-cod1A-totals
			move wae-d-cod2A-totals to wae-cod2A-totals
			move wae-d-cod3A-totals to wae-cod3A-totals
			move wae-d-cod4A-totals to wae-cod4A-totals.
		if waa-print-flag = 3
			move wae-p-comc1-totals to wae-comc1-totals
			move wae-p-comc2-totals to wae-comc2-totals
			move wae-p-comc3-totals to wae-comc3-totals
			move wae-p-comc1A-totals to wae-comc1A-totals
			move wae-p-comc2A-totals to wae-comc2A-totals
			move wae-p-comc3A-totals to wae-comc3A-totals
			move wae-p-cod1-totals to wae-cod1-totals
			move wae-p-cod2-totals to wae-cod2-totals
			move wae-p-cod3-totals to wae-cod3-totals
			move wae-p-cod4-totals to wae-cod4-totals
			move wae-p-cod1A-totals to wae-cod1A-totals
			move wae-p-cod2A-totals to wae-cod2A-totals
			move wae-p-cod3A-totals to wae-cod3A-totals
			move wae-p-cod4A-totals to wae-cod4A-totals.
			
	yb055-comm-chg1.
		move wae-comc1-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb060-comm-chg1-admin.
		if waa-special-prt = zero
			string "      COMM CHARGE 1     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0920 COMM CHARGE 1     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb060-comm-chg1-admin.
		move wae-comc1A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb065-comm-chg2.
		if waa-special-prt = zero
			string "      COMM CHG 1 ADMIN  " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 5920 COMM CHG 1 ADMIN  " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb065-comm-chg2.
		move wae-comc2-totals to waf-data.
		perform zb-format-line.
		if  waa-fmt-flag not = zero
			go to yb070-comm-chg2-admin.
		if waa-special-prt = zero
			string "      COMM CHARGE 2     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 1920 COMM CHARGE 2     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb070-comm-chg2-admin.
		move wae-comc2A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb075-comm-chg3.
		if waa-special-prt = zero
			string "      COMM CHG 2 ADMIN  " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 6920 COMM CHG 2 ADMIN  " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb075-comm-chg3.
		move wae-comc3-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb080-comm-chg3-admin.
		if waa-special-prt = zero
			string "      COMM CHARGE 3     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 2920 COMM CHARGE 3     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb080-comm-chg3-admin.
		move wae-comc3A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb085-co-1.
		if waa-special-prt = zero
			string "      COMM CHG 3 ADMIN  " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 7920 COMM CHG 3 ADMIN  " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb085-co-1.
		move wae-cod1-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb090-co-1-admin.
		if waa-special-prt = zero
			string "      COURT ORDER 1     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0924 COURT ORDER 1     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb090-co-1-admin.
		move wae-cod1A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb095-co-2.
		if waa-special-prt = zero
			string "      COURT ORD 1 ADMIN " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 5924 COURT ORD 1 ADMIN " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb095-co-2.
		move wae-cod2-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb100-co-2-admin.
		if waa-special-prt = zero
			string "      COURT ORDER 2     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 1924 COURT ORDER 2     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb100-co-2-admin.
		move wae-cod2A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb105-co-3.
		if waa-special-prt = zero
			string "      COURT ORD 2 ADMIN " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 6924 COURT ORD 2 ADMIN " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb105-co-3.
		move wae-cod3-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb105-co-3-admin.
		if waa-special-prt = zero
			string "      COURT ORDER 3     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 2924 COURT ORDER 3     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb105-co-3-admin.
		move wae-cod3A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb110-co-4.
		if waa-special-prt = zero
			string "      COURT ORD 3 ADMIN " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 7924 COURT ORD 3 ADMIN " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb110-co-4.
		move wae-cod4-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb115-co-4-admin.
		if waa-special-prt = zero
			string "      COURT ORDER 4     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 3924 COURT ORDER 4     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb115-co-4-admin.
		move wae-cod4A-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb117-aeos.
		if waa-special-prt = zero
			string "      COURT ORD 4 ADMIN " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 8924 COURT ORD 4 ADMIN " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb117-aeos.
		move wae-aeos-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb118-pri1.
		if waa-special-prt = zero
			string "      A. E. O. S        " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " n910/n912 A. E. O. S   " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb118-pri1.
		move wae-pri1-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb119-sl.
		if waa-special-prt = zero
			string "      PRI CRT ORD 1     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " n922 PRI CRT ORD 1     "  waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb119-sl.
		if waa-print-flag = 2
			move wae-d-sl-totals to wae-sl-totals.
		if waa-print-flag = 3
			move wae-p-sl-totals to wae-sl-totals.
		move wae-sl-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb120-debt.
		if waa-special-prt = zero
			string "      STUDENT LOAN      " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 4912 STUDENT LOAN      " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb120-debt.
		if waa-print-flag = 2
			move wae-d-debt-totals to wae-debt-totals.
		if waa-print-flag = 3
			move wae-p-debt-totals to wae-debt-totals.
		move wae-debt-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb130-round.
		if waa-special-prt = zero
			string "      DEBT              " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0928 DEBT              " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb130-round.
		if waa-print-flag = 2
			move wae-d-round-totals to wae-round-totals.
		if waa-print-flag = 3
			move wae-p-round-totals to wae-round-totals.
		move wae-round-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yb135-ded-total.
		if waa-special-prt = zero
			string "      ROUND             " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0946 ROUND             " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yb135-ded-total.
		move waf-underline to waf-print-line.
		perform za-print-line.
		move wae-ded-totals to waf-data.
		perform zb-format-line.
		string "   TOTAL: DEDUCTIONS    " waf-fmt-line
			delimited by size into waf-print-line.
		perform za-print-line.
		perform varying wab-maths-cnt from 1 by 1
					until wab-maths-cnt > 6
			subtract wae-total-ded(wab-maths-cnt) from
				wae-gross-pay(wab-maths-cnt)
				giving wae-net-pay(wab-maths-cnt)
		end-perform.
		if waa-print-flag = 2
			move wae-d-mits-net to wae-mits-net.
		if waa-print-flag = 3
			move wae-p-mits-net to wae-mits-net.
		move wae-net-totals to waf-data.
		move wae-mits-net-pay(1) to waf-data-column(1).
		move wae-mits-net-pay(6) to waf-data-column(6).
		perform zb-format-line.
		string "   TOTAL: NET PAY       " waf-fmt-line
			delimited by size into waf-print-line.
		perform za-print-line.

	yb155-difference.
		if wae-net-pay(2) = wae-mits-net-pay(2)
			if wae-net-pay(4) = wae-mits-net-pay(4)
				if wae-net-pay(5) = wae-mits-net-pay(5)
					go to yb990-reset.
		move waf-data to wag-data-num1.
		move wae-mits-net to wag-data-num2.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wag-data-num2 to waf-data.
		perform zb-format-line.
		move spaces to
			waf-fmt-column(1)
			waf-fmt-column(3)
			waf-fmt-column(6).
		string "   TOTAL: DIFFERENCE    " waf-fmt-line
			delimited by size into waf-print-line.
		perform za-print-line.

	yb990-reset.
		move spaces to waf-current-alpha.

	yb999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yc-tax-prt						section.

	yc000-start.
		if waa-print-flag = 2
			move wae-d-tax-tax to wae-tax-tax
			move wae-d-tax-taxable to wae-tax-taxable
			move wae-d-p45-taxable to wae-p45-taxable
			move wae-d-p45-tax to wae-p45-tax
			move wae-d-non-tax-totals to wae-non-tax-totals
			move wae-d-ftc-totals to wae-ftc-totals.
		if waa-print-flag = 3
			move wae-p-tax-tax to wae-tax-tax
			move wae-p-tax-taxable to wae-tax-taxable
			move wae-p-p45-taxable to wae-p45-taxable
			move wae-p-p45-tax to wae-p45-tax
			move wae-p-non-tax-totals to wae-non-tax-totals
			move wae-p-ftc-totals to wae-ftc-totals.
		if wae-tax-tax = zero
			and wae-tax-taxable = zero
			and wae-p45-taxable = zero
			and wae-p45-tax = zero
			and wae-non-tax-totals = zero
			and wae-ftc-totals = zero
				go to yc999-exit.
		move "TAX:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to waa-prt-eof wag-data-numbers.
		perform za-print-line.
		move "TAX CONTINUED...." to waf-current-alpha.

	yc005-this-emp-taxable.
		move wae-tax-taxable to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yc015-this-emp-tax.
		if waa-special-prt = zero
			string "      THIS EMPL TAXABLE " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0852 THIS EMPL TAXABLE " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yc015-this-emp-tax.
		move wae-tax-tax to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yc020-p45-taxable.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-tax-tot(5) to wad-summ-amt
				move 1 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-tax-tot(5) to wae-p-summ(1).
		if waa-special-prt = zero
			string "      THIS EMPL TAX     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0856 THIS EMPL TAX     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yc020-p45-taxable.
		move wae-p45-taxable to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yc025-p45-tax.
		if waa-special-prt = zero
			string "      P45 TAXABLE       " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0850 P45 TAXABLE       " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yc025-p45-tax.
		move wae-p45-tax to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yc030-non-tax.
		if waa-special-prt = zero
			string "      P45 TAX           " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0854 P45 TAX           " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yc030-non-tax.
		move wae-non-tax-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yc990-reset.
		if waa-special-prt = zero
			string "      NON TAXABLE       " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 242-265  NON TAXABLE   " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yc990-reset.
		move spaces to waf-current-alpha.

	yc999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yd-ni-prt						section.

	yd000-start.
		if waa-print-flag = 2
			move wae-d-eesni-totals to wae-eesni-totals
			move wae-d-ersni-totals to wae-ersni-totals
			move wae-ersni-dept-totals to wae-ers-totals
			move wae-ees-dept-totals to wae-ees-totals
			move wae-niable-depts to wae-niables-totals.
		if waa-print-flag = 3
			move wae-p-eesni-totals to wae-eesni-totals
			move wae-p-ersni-totals to wae-ersni-totals
			move wae-ersni-payroll-totals to wae-ers-totals
			move wae-ees-payroll-totals to wae-ees-totals
			move wae-niable-payroll to wae-niables-totals.
		if wae-niables-totals = zero
			if wae-ees-totals = zero
				if wae-ers-totals = zero
					go to yd999-exit.
		move "N.I.:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to
			waa-prt-eof
			wag-data-numbers.
		perform za-print-line.
		move "N.I. CONTINUED...." to waf-current-alpha.
		move zero to wab-ni-cnt.

	yd005-niable.
		add 1 to wab-ni-cnt.
		if wab-ni-cnt > 10
			go to yd035-p-totals.
		if wab-ni-cnt = 1
			move wae-niable-a-totals to waf-data
			move "A : " to wah-ni-tab.
		if wab-ni-cnt = 2
			move wae-niable-b-totals to waf-data
			move "B : " to wah-ni-tab.
		if wab-ni-cnt = 3
			move wae-niable-c-totals to waf-data
			move "C : " to wah-ni-tab.
		if wab-ni-cnt = 4
			move wae-niable-d-totals to waf-data
			move "D : " to wah-ni-tab.
		if wab-ni-cnt = 5
			move wae-niable-e-totals to waf-data
			move "E : " to wah-ni-tab.
		if wab-ni-cnt = 6
			move wae-niable-l-totals to waf-data
			if waa-use-nicalc5-mkr = zero
				move "CO: " to wah-ni-tab
				else
				move "L : " to wah-ni-tab.
		if wab-ni-cnt = 7
			move wae-niable-f-totals to waf-data
			move "F : " to wah-ni-tab.
		if wab-ni-cnt = 8
			move wae-niable-g-totals to waf-data
			move "G : " to wah-ni-tab.
		if wab-ni-cnt = 9
			move wae-niable-s-totals to waf-data
			move "S : " to wah-ni-tab.
		if wab-ni-cnt = 10
			move wae-niable-j-totals to waf-data
			move "J : " to wah-ni-tab.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " NIABLE       " waf-fmt-line
				delimited by size into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.
		if wab-ni-cnt = 1
			move wae-tolel-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-tolel-b-totals to waf-data.
		if wab-ni-cnt = 3
			move wae-tolel-c-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-tolel-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-tolel-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-tolel-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-tolel-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-tolel-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-tolel-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-tolel-j-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " NIABLE-TOLEL " waf-fmt-line
				delimited by size into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.
		if wab-ni-cnt = 1
			move wae-toet-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-toet-b-totals to waf-data.
		if wab-ni-cnt = 3
			move wae-toet-c-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-toet-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-toet-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-toet-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-toet-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-toet-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-toet-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-toet-j-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string	wah-ni-str
				" NIABLE-" wad-ni-nar1 "  "
				waf-fmt-line
				delimited by size
					into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.
		if wab-ni-cnt = 1
			move wae-touap-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-touap-b-totals to waf-data.
		if wab-ni-cnt = 3
			move wae-touap-c-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-touap-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-touap-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-touap-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-touap-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-touap-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-touap-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-touap-j-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string	wah-ni-str
				" NIABLE-TOUAP "
				waf-fmt-line
				delimited by size
					into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.
		if wab-ni-cnt = 1
			move wae-touel-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-touel-b-totals to waf-data.
		if wab-ni-cnt = 3
			move wae-touel-c-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-touel-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-touel-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-touel-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-touel-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-touel-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-touel-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-touel-j-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " NIABLE-TOUEL " waf-fmt-line
				delimited by size into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.
		if wab-ni-cnt = 1
			move wae-uelplus-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-uelplus-b-totals to waf-data.
		if wab-ni-cnt = 3
			move wae-uelplus-c-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-uelplus-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-uelplus-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-uelplus-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-uelplus-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-uelplus-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-uelplus-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-uelplus-j-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " NIABLE-UEL+  " waf-fmt-line
				delimited by size into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.

	yd015-ees.
		if wab-ni-cnt = 3
			go to yd025-ers.
		if wab-ni-cnt = 1
			move wae-ees-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-ees-b-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-ees-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-ees-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-ees-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-ees-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-ees-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-ees-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-ees-j-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move waf-data-column(5) to wad-summ-amt
				move 5 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add waf-data-column(5) to wae-p-summ(5).
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " EES          " waf-fmt-line
				delimited by size into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.

	yd025-ers.
		if wab-ni-cnt = 1
			move wae-ersni-a-totals to waf-data.
		if wab-ni-cnt = 2
			move wae-ersni-b-totals to waf-data.
		if wab-ni-cnt = 3
			move wae-ersni-c-totals to waf-data.
		if wab-ni-cnt = 4
			move wae-ersni-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-ersni-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-ersni-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-ersni-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-ersni-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-ersni-s-totals to waf-data.
		if wab-ni-cnt = 10
			move wae-ersni-j-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move waf-data-column(5) to wad-summ-amt
				move 5 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add waf-data-column(5) to wae-p-summ(5).
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " ERS          " waf-fmt-line
				delimited by size into waf-print-line
			move spaces to wah-ni-tab
			perform za-print-line.
		if not (wab-ni-cnt = 4 or 7)
			go to yd027-ersreb.
		if waa-use-nicalc5-mkr not = zero
			go to yd027-ersreb.
		if wab-ni-cnt = 4
			move wae-eesreb-d-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-eesreb-f-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move waf-data-column(5) to wad-summ-amt
				move 10 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add waf-data-column(5) to wae-p-summ(10).
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " EES REBATE   " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.
		move spaces to wah-ni-tab.

	yd027-ersreb.
		if waa-use-nicalc5-mkr not = zero
			go to yd030-totals.
		if wab-ni-cnt < 4
			go to yd030-totals.
		if wab-ni-cnt = 4
			move wae-ersreb-d-totals to waf-data.
		if wab-ni-cnt = 5
			move wae-ersreb-e-totals to waf-data.
		if wab-ni-cnt = 6
			move wae-ersreb-l-totals to waf-data.
		if wab-ni-cnt = 7
			move wae-ersreb-f-totals to waf-data.
		if wab-ni-cnt = 8
			move wae-ersreb-g-totals to waf-data.
		if wab-ni-cnt = 9
			move wae-ersreb-s-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move waf-data-column(5) to wad-summ-amt
				move 10 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add waf-data-column(5) to wae-p-summ(10).
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " ERS REBATE   " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.
		move spaces to wah-ni-tab.

	yd030-totals.
		if wab-ni-cnt = 3
			go to yd005-niable.
		if wab-ni-cnt = 1
			move wae-ees-a-totals to wag-data-num1
			move wae-ersni-a-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 2
			move wae-ees-b-totals to wag-data-num1
			move wae-ersni-b-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 4
			move wae-ees-d-totals to wag-data-num1
			move wae-ersni-d-totals to wag-data-num2
			perform zx-add-subtract
			move wae-ersreb-d-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wae-eesreb-d-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 5
			move wae-ees-e-totals to wag-data-num1
			move wae-ersni-e-totals to wag-data-num2
			perform zx-add-subtract
			move wae-ersreb-e-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 6
			move wae-ees-l-totals to wag-data-num1
			move wae-ersni-l-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 7
			move wae-ees-f-totals to wag-data-num1
			move wae-ersni-f-totals to wag-data-num2
			perform zx-add-subtract
			move wae-ersreb-f-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wae-eesreb-f-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 8
			move wae-ees-g-totals to wag-data-num1
			move wae-ersni-g-totals to wag-data-num2
			perform zx-add-subtract
			move wae-ersreb-g-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 9
			move wae-ersni-s-totals to wag-data-num2
			move wae-ersreb-s-totals to wag-data-num1
			move 1 to waa-add-sub-flag
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		if wab-ni-cnt = 10
			move wae-ees-j-totals to wag-data-num1
			move wae-ersni-j-totals to wag-data-num2
			perform zx-add-subtract
			move wag-data-num2 to wae-nitot-totals.
		move wae-nitot-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str " TOTAL NI     " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.
		go to yd005-niable.

	yd035-p-totals.
		move "P :  " to wah-ni-tab.
		move wae-ersni-p-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
			    move waf-data-column(5) to wad-summ-amt
			    if waa-use-nicalc5-mkr = zero
				move 9 to wad-summ-cnt
				else
				move 13 to wad-summ-cnt
			    end-if
			    perform xi-update-summ-fl.
		if waa-print-flag = 3
		    if waa-use-nicalc5-mkr = zero
			add waf-data-column(5) to wae-p-summ(9)
			else
			add waf-data-column(5) to wae-p-summ(13).
		perform zb-format-line.
		if waa-fmt-flag = zero
			string wah-ni-str "  ERS REDUCT'N" waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	yd035-tables-totals.
		move waf-underline to waf-print-line.	
		perform za-print-line.
		move wae-eesni-totals to wag-data-num1.
		move wae-ersni-totals to wag-data-num2.
		perform zx-add-subtract.
		move wag-data-num2 to wae-nitot-totals.
		move wae-nitot-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string "   TOTAL: ALL TABLES    " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	yd990-reset.
		move spaces to waf-current-alpha.

	yd999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ye-dss-prt						section.

	ye000-start.
		move wae-notion-ssp-totals to wae-ssp-rec-totals.
      *		move wae-notion-smp-totals to wae-smp-rec-totals.
      *		move wae-notion-sap-totals to wae-sap-rec-totals.
      *		move wae-notion-spp-totals to wae-spp-rec-totals.
		if waa-print-flag = 2
			move wae-d-notion-ssp-totals to
				wae-ssp-rec-totals
			move wae-d-smp-com-totals to
				wae-smp-com-totals
			move wae-d-sap-com-totals to
				wae-sap-com-totals
			move wae-d-spp-com-totals to
				wae-spp-com-totals
			move wae-d-aspp-com-totals to
				wae-aspp-com-totals
			move wae-d-smp-totals to
				wae-smp-totals
			move wae-d-sap-totals to
				wae-sap-totals
			move wae-d-spp-totals to
				wae-spp-totals
			move wae-d-aspp-totals to
				wae-aspp-totals
			move wae-d-smp-rec-totals to
				wae-smp-rec-totals
			move wae-d-sap-rec-totals to
				wae-sap-rec-totals
			move wae-d-spp-rec-totals to
				wae-spp-rec-totals
			move wae-d-aspp-rec-totals to
				wae-aspp-rec-totals
			move wae-d-sl-totals to
				wae-sl-totals
			move wae-d-ftc-totals to
				wae-ftc-totals.
		if waa-print-flag = 3
			move wae-p-notion-ssp-totals to
				wae-ssp-rec-totals
			move wae-p-smp-com-totals to
				wae-smp-com-totals
			move wae-p-sap-com-totals to
				wae-sap-com-totals
			move wae-p-spp-com-totals to
				wae-spp-com-totals
			move wae-p-aspp-com-totals to
				wae-aspp-com-totals
			move wae-p-smp-totals to
				wae-smp-totals
			move wae-p-sap-totals to
				wae-sap-totals
			move wae-p-spp-totals to
				wae-spp-totals
			move wae-p-aspp-totals to
				wae-aspp-totals
			move wae-p-smp-rec-totals to
				wae-smp-rec-totals
			move wae-p-sap-rec-totals to
				wae-sap-rec-totals
			move wae-p-spp-rec-totals to
				wae-spp-rec-totals
			move wae-p-aspp-rec-totals to
				wae-aspp-rec-totals
			move wae-p-sl-totals to
				wae-sl-totals
			move wae-p-ftc-totals to
				wae-ftc-totals.
		perform zy-ssp-recovery.
		if wae-ssp-rec-totals = zero
			and wae-smp-rec-totals = zero
			and wae-sap-rec-totals = zero
			and wae-spp-rec-totals = zero
			and wae-aspp-rec-totals = zero
			and wae-smp-com-totals = zero
			and wae-sap-com-totals = zero
			and wae-spp-com-totals = zero
			and wae-aspp-com-totals = zero
			and wae-smp-totals = zero
			and wae-sap-totals = zero
			and wae-spp-totals = zero
			and wae-aspp-totals = zero
			and wae-nitot-totals = zero
			and wae-sl-totals = zero
			and wae-ftc-totals = zero
				go to ye999-exit.

	ye005-set-up.
		move "D.S.S.:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to waa-prt-eof wag-data-numbers.
		perform za-print-line.
		move "D.S.S. CONTINUED...." to waf-current-alpha.
		move zero to wab-ni-cnt.

	ye010-ssp-recovery.
		move wae-ssp-rec-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string "      SSP RECOVERY      " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	ye015-smp-recovery.
		move wae-smp-rec-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ye016-sap-recovery.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-smp-rec-pay(5) to wad-summ-amt
				move 7 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-smp-rec-pay(5) to wae-p-summ(7).
		if waa-special-prt = zero
			string "      SMP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line
			else
			string " 1272 SMP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line.
		perform za-print-line.

	ye016-sap-recovery.
		if waa-use-nicalc5-mkr = zero
			go to ye017-spp-recovery.
		move wae-sap-rec-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ye017-spp-recovery.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-sap-rec-pay(5) to wad-summ-amt
				move 11 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-sap-rec-pay(5) to wae-p-summ(11).
		if waa-special-prt = zero
			string "      SAP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line
			else
			string " 3272 SAP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line.
		perform za-print-line.

	ye017-spp-recovery.
		if waa-use-nicalc5-mkr = zero
			go to ye018-aspp-recovery.
		move wae-spp-rec-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ye018-aspp-recovery.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-spp-rec-pay(5) to wad-summ-amt
				move 9 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-spp-rec-pay(5) to wae-p-summ(9).
		if waa-special-prt = zero
			string "     OSPP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line
			else
			string "4272 OSPP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line.
		perform za-print-line.

	ye018-aspp-recovery.
		if waa-use-nicalc5-mkr = zero
			go to ye020-smp-compensation.
		move wae-aspp-rec-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ye020-smp-compensation.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-aspp-rec-pay(5) to wad-summ-amt
				move 9 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-aspp-rec-pay(5) to wae-p-summ(9).
		if waa-special-prt = zero
			string "     ASPP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line
			else
			string "6272 ASPP REC AT "
				waf-smp-rec-fmt
				"%" waf-fmt-line
					delimited by size
					into waf-print-line.
		perform za-print-line.

	ye020-smp-compensation.
		move wae-smp-com-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string "      SMP COMPENSATION  " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	ye021-sap-compensation.
		move wae-sap-com-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string "      SAP COMPENSATION  " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	ye022-spp-compensation.
		move wae-spp-com-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string "     OSPP COMPENSATION " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	ye023-aspp-compensation.
		move wae-aspp-com-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			string "     ASPP COMPENSATION " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	ye025-sl-totals.
		move wae-sl-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-sl-tot(5) to wad-summ-amt
				move 2 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-sl-tot(5) to wae-p-summ(2).
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ye030-ftc-totals.
		if waa-special-prt = zero
			string "      STUDENT LOANS     " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 4912 STUDENT LOANS     " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ye030-ftc-totals.
		move wae-ftc-totals to waf-data.
		if waa-summ-flag not = zero
			if waa-print-flag = 2
				move wae-ftc-pay(5) to wad-summ-amt
				move 3 to wad-summ-cnt
				perform xi-update-summ-fl.
		if waa-print-flag = 3
			add wae-ftc-pay(5) to wae-p-summ(3).
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to ye050-dss-totals.
		if waa-special-prt = zero
			string "      TAX CREDITS       " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 5272 TAX CREDITS       " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	ye050-dss-totals.
		move wae-smp-rec-totals to wag-data-num1.
		move wae-smp-com-totals to wag-data-num2.
		perform zx-add-subtract.
		move wae-sap-rec-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-spp-rec-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-aspp-rec-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-sap-com-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-spp-com-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-aspp-com-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-ssp-rec-totals to wag-data-num1.
		perform zx-add-subtract.
		move wae-ftc-totals to wag-data-num1.
		perform zx-add-subtract.
		move 1 to waa-add-sub-flag.
		move wag-data-num2 to wag-data-num1.
		move wae-nitot-totals to wag-data-num2.
		perform zx-add-subtract.
		move wae-sl-totals to wag-data-num1.
		perform zx-add-subtract.
		move wag-data-num2 to wae-dss-tote waf-data.
		perform zb-format-line.
		if waa-fmt-flag = zero
			move waf-underline to waf-print-line
			perform za-print-line
			string "   TOTAL: TO D.S.S.     " waf-fmt-line
				delimited by size into waf-print-line
			perform za-print-line.

	ye990-reset.
		move spaces to waf-current-alpha.

	ye999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yg-3rd-prt						section.

	yg000-start.
		move low-values to fa-key fb-key fc-key.
		if waa-print-flag = 1
			start fa-pay-fl key not < fa-key invalid key
				go to yg999-exit.
		if waa-print-flag = 2
			move wae-d-smp-rec-totals to
				wae-smp-rec-totals
			move wae-d-sap-rec-totals to
				wae-sap-rec-totals
			move wae-d-spp-rec-totals to
				wae-spp-rec-totals
			move wae-d-aspp-rec-totals to
				wae-aspp-rec-totals
			move wae-d-ersni-totals to wae-ersni-totals
			move wae-d-gross-totals to wae-gross-totals
			move wae-d-3rd-totals to wae-3rd-totals
			move wae-d-3rd-not-inc to wae-3rd-not-inc
			start fb-pay-fl key not < fb-key invalid key
				go to yg999-exit.
		if waa-print-flag = 3
			move wae-p-smp-rec-totals to
				wae-smp-rec-totals
			move wae-p-sap-rec-totals to
				wae-sap-rec-totals
			move wae-p-spp-rec-totals to
				wae-spp-rec-totals
			move wae-p-aspp-rec-totals to
				wae-aspp-rec-totals
			move wae-p-ersni-totals to wae-ersni-totals
			move wae-p-gross-totals to wae-gross-totals
			move wae-p-3rd-totals to wae-3rd-totals
			move wae-p-3rd-not-inc to wae-3rd-not-inc
			start fc-pay-fl key not < fc-key invalid key
				go to yg999-exit.
		if wae-3rd-totals = zero
			and wae-ersni-totals = zero
				go to yg045-total-cost.
		move "3RD PARTIES:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to waa-prt-eof wag-data-numbers.
		perform za-print-line.
		move "3RD PARTIES CONTINUED...." to waf-current-alpha.
		move zero to wab-ni-cnt.

	yg005-which-files.
		go to
			yg015-sub-dept-file
			yg020-dept-file
			yg010-payroll-file
				depending on waa-print-flag.
		go to yg999-exit.

	yg010-payroll-file.
		read fc-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fc-pay-rec to waf-pay-rec.
		go to yg025-end-pay-fls.

	yg015-sub-dept-file.
		read fa-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fa-pay-rec to waf-pay-rec.
		go to yg025-end-pay-fls.

	yg020-dept-file.
		read fb-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fb-pay-rec to waf-pay-rec.

	yg025-end-pay-fls.
		if waa-prt-eof not = zero
			go to yg035-ers-ni.
		if waf-rec-type not = "3"
			go to yg005-which-files.

	yg030-test-record.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yg005-which-files.
		string waf-descrip waf-fmt-line delimited by size
			into waf-print-line.
		perform za-print-line
		go to yg005-which-files.

	yg035-ers-ni.
		move wae-ersni-totals to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yg040-ers-pension.
		if waa-special-prt = zero
			string "      NET ERS NI        " waf-fmt-line
				delimited by size into waf-print-line
		else
			string " 0706-0786 NET ERS NI   " waf-fmt-line
				delimited by size into waf-print-line.
		perform za-print-line.

	yg040-ers-pension.
		go to yg045-total-cost.

	yg045-total-cost.
		move wae-ersni-totals to wag-data-num1.
		move wae-3rd-totals to wae-save-3rd-totals.
		move wae-3rd-totals to wag-data-num2.
		perform zx-add-subtract.
		move wae-gross-totals to wag-data-num1.
		perform zx-add-subtract.
		move wag-data-num2 to wae-3rd-totals.
		move wae-ssp-rec-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-smp-com-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-sap-com-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-spp-com-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-aspp-com-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-smp-rec-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-sap-rec-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-spp-rec-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move wae-aspp-rec-totals to wag-data-num1.
		move 1 to waa-add-sub-flag.
		perform zx-add-subtract.
		move 1 to waa-add-sub-flag.
		move wae-3rd-not-inc to wag-data-num1.
		perform zx-add-subtract.
		move wag-data-num2 to wae-3rd-totals.
		move 1 to waa-add-sub-flag.
		move wae-ftc-totals to wag-data-num1.
		perform zx-add-subtract.
		move wag-data-num2 to waf-data.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yg990-reset.
		move waf-underline to waf-print-line.
		perform za-print-line.
		string "   TOTAL: PAYROLL COST  " waf-fmt-line
			delimited by size into waf-print-line.
		move wae-save-3rd-totals to wae-3rd-totals.
		perform za-print-line.

	yg990-reset.
		move spaces to waf-current-alpha.

	yg999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yh-mth-prt						section.

	yh000-start.
		move 2 to wab-spacing.
		if waa-print-flag = 2
			move wab-dept-methods to wab-methods.
		if waa-print-flag = 3
			move wab-p-male-paid to wab-male-paid
			move wab-p-female-paid to wab-female-paid
			move wab-p-male-not-paid to wab-male-not-paid
			move wab-p-female-not-paid to
				wab-female-not-paid
			move wab-p-cash-cnt to wab-cash-cnt
	  		move wab-p-other-cnt to wab-other-cnt
			move wab-p-bank-cnt to wab-bank-cnt
			move wab-p-cash-amt to wab-cash-amt
	 	 	move wab-p-other-amt to wab-other-amt
			move wab-p-bank-amt to wab-bank-amt.
		move 56 to wab-test-cnt.
		if waa-print-flag = 2
			if fzlb-dept not = spaces
				subtract 2 from wab-test-cnt.
		if waa-print-flag = 3
			if fzlb-dept not = spaces
				subtract 2 from wab-test-cnt.
		if wab-throw-mkr = zero
			if wab-line-cnt not < wab-test-cnt
				move -4 to wab-margin
				if wab-cash-amt = zero
					move wad-paym-str1 to
						waf-print-line
				else
					move wad-paym-str2 to
						waf-print-line
				end-if
				perform za-print-line
				move 1 to wab-throw-mkr.
	
	yh007-clear.
		move zero to wae-result.
		move wab-cash-cnt to wac-cash-cnt.
		divide wab-cash-amt by 100 giving waf-divide.
		move waf-divide to wac-cash-amt.
		move wac-ft-line1 to waf-print-line.
		perform za-print-line.

	yh010-other.
		move zero to wae-result.
		move wab-male-cnt to wab-male-not-paid.
		subtract wab-male-paid from wab-male-not-paid.
		subtract wab-male-left-cnt from wab-male-not-paid.
		move wab-male-left-cnt to wac-male-left.
		move wab-male-paid to wac-male-paid.
		move wab-male-not-paid to wac-male-no-pay.
		add wab-male-paid to wae-result.
		add wab-male-not-paid to wae-result.
		add wae-result to wab-male-left-cnt
			giving wab-male-total.
		move wab-male-total to wac-male-total.
		move wab-other-cnt to wac-other-cnt.
		divide wab-other-amt by 100 giving waf-divide.
		move waf-divide to wac-other-amt.
		move wac-ft-line2 to waf-print-line.
		perform za-print-line.

	yh010-bank.
		move zero to wae-result.
		move wab-female-cnt to wab-female-not-paid.
		subtract wab-female-paid from wab-female-not-paid.
		subtract wab-female-left-cnt from wab-female-not-paid.
		add wab-female-paid to wae-result.
		add wab-female-left-cnt to wae-result.
		add wab-female-not-paid to wae-result
			giving wab-female-total.
		move wab-female-total to wac-female-total.
		move wab-female-left-cnt to wac-female-left.
		move wab-female-paid to wac-female-paid.
		move wab-female-not-paid to wac-female-no-pay.
		move wab-bank-cnt to wac-bank-cnt.
		divide wab-bank-amt by 100 giving waf-divide.
		move waf-divide to wac-bank-amt.
		move wac-ft-line3 to waf-print-line.
		perform za-print-line.

	yh015-under-total.
		add wab-male-not-paid to wab-female-not-paid
			giving wac-no-pay-total.
		add wab-male-paid to wab-female-paid
			giving wac-paid-total.
		add wab-male-total to wab-female-total
			giving wac-overall-total.
		add wab-male-left-cnt to wab-female-left-cnt
			giving wac-left-total.
		move wac-ft-line4 to waf-print-line.
		perform za-print-line.

	yh020-dss-dets.
		if waa-special-split not = zero
			go to yh999-exit.
		if waa-print-flag = 1
			go to yh999-exit.
		if waa-print-flag = 2
			if fzlb-dept = spaces
				go to yh999-exit.
		move 2 to wab-spacing.
		move wac-ft-line8 to waf-print-line.
		perform za-print-line.
		move zero to wab-margin.

	yh999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yi-csh-prt						section.

	yi000-start.
		if waa-print-flag = 1
			if wac-cash-vars = zero
				go to yi999-exit.
		if waa-print-flag = 2
	 	 	if wac-d-cash-vars = zero
				go to yi999-exit
			end-if
			move wac-d-cash-vars to wac-cash-vars.
		if waa-print-flag = 3
	  		if wac-p-cash-vars = zero
				go to yi999-exit
			end-if
			move wac-p-cash-vars to wac-cash-vars.
		perform varying wab-cnt from 1 by 1 until wab-cnt > 11
			move wac-csh-cnts(wab-cnt) to
				wac-cash-cnts(wab-cnt)
		end-perform.
		move wac-cash-amt to wac-csh-amt(12).
		multiply wac-csh-cnts(1) by 50 giving wac-csh-amt(1).
		multiply wac-csh-cnts(2) by 20 giving wac-csh-amt(2).
		multiply wac-csh-cnts(3) by 10 giving wac-csh-amt(3).
		multiply wac-csh-cnts(4) by 5 giving wac-csh-amt(4).
		multiply wac-csh-cnts(5) by 1 giving wac-csh-amt(5).
		multiply wac-csh-cnts(6) by 50 giving wae-result.
		divide wae-result by 100 giving wac-csh-amt(6).
		multiply wac-csh-cnts(7) by 20 giving wae-result.
		divide wae-result by 100 giving wac-csh-amt(7).
		multiply wac-csh-cnts(8) by 10 giving wae-result.
		divide wae-result by 100 giving wac-csh-amt(8).
		multiply wac-csh-cnts(9) by 5 giving wae-result.
		divide wae-result by 100 giving wac-csh-amt(9).
		multiply wac-csh-cnts(10) by 2 giving wae-result.
		divide wae-result by 100 giving wac-csh-amt(10).
		divide wac-csh-cnts(11) by 100 giving wac-csh-amt(11).
		if wab-throw-mkr = zero
		    if wab-line-cnt not < 57
			move -4 to wab-margin
			move "CASH ANALYSIS FOLLOWS ON NEXT PAGE" to
				waf-print-line
			perform za-print-line
			move 1 to wab-throw-mkr.
		move wac-ft-line5 to waf-print-line.
		perform za-print-line.
		move wac-ft-line6 to waf-print-line.
		perform za-print-line.
		move wac-ft-line7 to waf-print-line.
		perform za-print-line.
		move zero to wab-margin.

	yi999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yj-notionals						section.

	yj000-start.
		move low-values to fa-key fb-key fc-key.
		if waa-print-flag = 1
			start fa-pay-fl key not < fa-key invalid key
				go to yj999-exit.
		if waa-print-flag = 2
			start fb-pay-fl key not < fb-key invalid key
				go to yj999-exit.
		if waa-print-flag = 3
			start fc-pay-fl key not < fc-key invalid key
				go to yj999-exit.
		if waa-print-flag = 3
			if waa-p-notion-flag = zero
				go to yj999-exit.
		if waa-print-flag = 2
			if waa-d-notion-flag = zero
				go to yj999-exit.
		if waa-print-flag = 1
			if waa-notion-flag = zero
				go to yj999-exit.
		move "NOTIONALS:" to waf-print-line.	
		move 1 to wab-margin.
		move zero to waa-prt-eof wag-data-numbers.
		perform za-print-line.
		move "NOTIONALS CONTINUED...." to waf-current-alpha.
		move zero to wab-ni-cnt.

	yj005-which-files.
		go to
			yj015-sub-dept-file
			yj020-dept-file
			yj010-payroll-file
				depending on waa-print-flag.
		go to yj999-exit.

	yj010-payroll-file.
		read fc-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fc-pay-rec to waf-pay-rec.
		move fc-key to waf-data-code.
		go to yj025-end-notionals.

	yj015-sub-dept-file.
		read fa-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fa-pay-rec to waf-pay-rec.
		move fa-key to waf-data-code.
		go to yj025-end-notionals.

	yj020-dept-file.
		read fb-pay-fl next record
			at end
			move 1 to waa-prt-eof.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fb-pay-rec to waf-pay-rec.
		move fb-key to waf-data-code.

	yj025-end-notionals.
		if waa-prt-eof not = zero
			go to yj990-reset.
		if waf-rec-type not = "N"
			go to yj005-which-files.
		perform zb-format-line.
		if waa-fmt-flag not = zero
			go to yj005-which-files.
		move "PAY" to waf-pay-ded.
		if waf-code not < "274" and not > "279"
			go to yj050-common.
		if waf-code not < "660" and not > "699"
			go to yj050-common.
		move "DED" to waf-pay-ded.
		if waf-code not < "364" and not > "383"
			go to yj050-common.
		if waf-code not < "416" and not > "429"
			go to yj050-common.
		if waf-code not < "538" and not > "549"
			go to yj050-common.
      *		if waf-code = "798"
		if waf-data-code = "7980"
			move "SSP TOTAL" to waf-desc-name
			go to yj050-common.
		move spaces to waf-pay-ded.

	yj050-common.
		string waf-descrip waf-fmt-line delimited by size
			into waf-print-line.
		perform za-print-line.
		move spaces to waf-pay-ded.
		go to yj005-which-files.

	yj990-reset.
		move spaces to waf-current-alpha.

	yj999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yk-gloss-desc						section.

	yk000-start.
		move wad-code to wad-norm-data.
		move wad-code-n to wad-norm-n.
		if waa-special-prt = zero
			move spaces to fa-desc-code
			else
			move wad-norm-code to fa-desc-code.
		move wad-norm-code to fva-data-code.
		move waf-fv-run-date to fva-date.
		read fv-variables-glossary
			invalid key
			move waf-fz-run-date to fza-date
			move wad-norm-code to fza-data-code
			read fz-variables-glossary into fvb-rec
				invalid key
				initialize fvb-rec.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fvb-desc to fa-desc-name.

	yk999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yl-cash-anal						section.

	yl000-start.
		move zero to wal-cash-group.
		if wae-result < zero
			display "-P? ca NEGATIVE NET PAY CALCULATED"
			go to yl999-exit.
		move wae-result to wal-net-pay.
		if wal-net-pay = zero
			go to yl999-exit.
		if waa-coinage-mkr = zero
			move 1 to waa-coinage-mkr
			open output ff-coinage-fl
			if wzz-io-err-code not = zero
				perform zza-io-err.
		move fab-key to fcf-key.
		move zero to fcf-amounts.
		move wae-result to wak-cash-amt.
		move wak-cash-amt to fcf-cash.
 	    if wal-pounds not < 1
			if fub-cash-analysis-1 = "1"
				add 1 to wac-csh-cnts(5)
				add 1 to fcf-amt(5)
				subtract 1 from wal-pounds.

	yl005-test-50.
		if wal-pounds < 50
			go to yl010-test-20.
		if fub-cash-analysis-50 = zero
			go to yl010-test-20.
		divide wal-pounds by 50 giving wal-50-cnt
			remainder wal-pnds-rem.
		subtract wal-pnds-rem from wal-pounds
			giving wal-csh-rem.
		add wal-50-cnt to wac-csh-cnts(1).
		add wal-50-cnt to fcf-amt(1).

	yl010-test-20.
		if wal-50-cnt not = zero
			move wal-pnds-rem to wal-pounds.
		if wal-pounds < 20
			go to yl015-test-10.
		divide wal-pounds by 20 giving wal-20-cnt
			remainder wal-pnds-rem.
		subtract wal-pnds-rem from wal-pounds
			giving wal-csh-rem.
		add wal-20-cnt to wac-csh-cnts(2).
		add wal-20-cnt to fcf-amt(2).

	yl015-test-10.
		if wal-20-cnt not = zero
			move wal-pnds-rem to wal-pounds.
		if wal-pounds < 10
			go to yl020-test-5.
		divide wal-pounds by 10 giving wal-10-cnt
			remainder wal-pnds-rem.
		subtract wal-pnds-rem from wal-pounds
			giving wal-csh-rem.
		add wal-10-cnt to wac-csh-cnts(3).
		add wal-10-cnt to fcf-amt(3).

	yl020-test-5.
		if wal-10-cnt not = zero
			move wal-pnds-rem to wal-pounds.
		if wal-pounds < 5
			go to yl025-test-1.
		divide wal-pounds by 5 giving wal-5-cnt
			remainder wal-pnds-rem.
		subtract wal-pnds-rem from wal-pounds
			giving wal-csh-rem.
		add wal-5-cnt to wac-csh-cnts(4).
		add wal-5-cnt to fcf-amt(4).

	yl025-test-1.
		if wal-5-cnt not = zero
			move wal-pnds-rem to wal-pounds.
		if wal-pounds < 1
			go to yl030-test-50p.	
		divide wal-pounds by 1 giving wal-1-cnt
			remainder wal-pnds-rem.
		subtract wal-pnds-rem from wal-pounds
			giving wal-csh-rem.
		add wal-1-cnt to wac-csh-cnts(5).
		add wal-1-cnt to fcf-amt(5).

	yl030-test-50p.
		if wal-pence < 50
			go to yl035-test-20p.
		divide wal-pence by 50 giving wal-50p-cnt
			remainder wal-pnce-rem.
		subtract wal-pnce-rem from wal-pence
			giving wae-result.
		divide wae-result by 100 giving waf-divide.
		add wal-50p-cnt to wac-csh-cnts(6).
		add wal-50p-cnt to fcf-amt(6).

	yl035-test-20p.
		if wal-50p-cnt not = zero
			move wal-pnce-rem to wal-pence.
		if wal-pence < 20
			go to yl040-test-10p.
		divide wal-pence by 20 giving wal-20p-cnt
			remainder wal-pnce-rem.
		subtract wal-pnce-rem from wal-pence
			giving wae-result.
		divide wae-result by 100 giving waf-divide.
		add wal-20p-cnt to wac-csh-cnts(7).
		add wal-20p-cnt to fcf-amt(7).

	yl040-test-10p.
		if wal-20p-cnt not = zero
			move wal-pnce-rem to wal-pence.
		if wal-pence < 10
			go to yl045-test-5p.
		divide wal-pence by 10 giving wal-10p-cnt
			remainder wal-pnce-rem.
		subtract wal-pnce-rem from wal-pence
			giving wae-result.
		divide wae-result by 100 giving waf-divide.
		add wal-10p-cnt to wac-csh-cnts(8).
		add wal-10p-cnt to fcf-amt(8).

	yl045-test-5p.
		if wal-10p-cnt not = zero
			move wal-pnce-rem to wal-pence.
		if wal-pence < 5
			go to yl050-test-2p.
		divide wal-pence by 5 giving wal-5p-cnt
			remainder wal-pnce-rem.
		subtract wal-pnce-rem from wal-pence
			giving wae-result.
		divide wae-result by 100 giving waf-divide.
		add wal-5p-cnt to wac-csh-cnts(9).
		add wal-5p-cnt to fcf-amt(9).

	yl050-test-2p.
		if wal-5p-cnt not = zero
			move wal-pnce-rem to wal-pence.
		if wal-pence < 2
			go to yl053-test-1p.
		divide wal-pence by 2 giving wal-2p-cnt
			remainder wal-pnce-rem.
		subtract wal-pnce-rem from wal-pence
			giving wae-result.
		divide wae-result by 100 giving waf-divide.
		add wal-2p-cnt to wac-csh-cnts(10).
		add wal-2p-cnt to fcf-amt(10).

	yl053-test-1p.
		if wal-2p-cnt not = zero
			move wal-pnce-rem to wal-pence.
		if wal-pence < 1
			go to yl900-write.
		divide wal-pence by 1 giving wal-1p-cnt.
		divide wal-1p-cnt by 100 giving waf-divide.
		add wal-1p-cnt to wac-csh-cnts(11).
		add wal-1p-cnt to fcf-amt(11).

	yl900-write.
		write ff-coinage-record.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	yl999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ym-negate-debt-round					section.

	ym000-start.
		subtract wag-num1-col(4) from zero
			giving wag-num1-col(4).
		subtract wag-num1-col(5) from zero
			giving wag-num1-col(5).
		subtract wag-num1-col(6) from zero
			giving wag-num1-col(6).

	ym999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	yn-footer-line						section.

	yn000-start.
		move wab-line-cnt to wza-line-count.
		perform za-setup-footer.
		write paa-print-line from wza-print-line after
				wza-footer-throw.

	yn999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	za-print-line						section.

	za000-start.
		move zero to waa-thrown.
		if wab-throw-mkr not = zero
			go to za010-prt-header.
		add	wab-line-cnt
			wab-spacing
			wab-margin
				giving wab-cnt.
		if wab-cnt not > wab-page-len
			go to za025-prt-line.

	za010-prt-header.
		move zero to wab-throw-mkr.
		if wab-page-cnt > zero
			perform yn-footer-line.
		add 1 to wab-page-cnt.
		move wab-page-cnt to wac-page-no.
		if waa-print-flag = 3
			move spaces to wac-dept-no
			move spaces to wac-dept-str
			call "mits01vu" using
				wac-dept-no
				fzlb-rec
				fub-rec
			move fzlb-tax-district-num to wac-tax-dist-ftl8
			move fzlb-permit-number to wac-permit-ftl8
			move fzlb-ers-ref-number to wac-tax-ref-ftl8
			move "CUMULATIVE " to wac-sub-string
			go to za015-pr-hl3.
      *		if waa-special-split not = zero
      *			and waa-scan not = zero
			if waa-scan not = zero
				move "CMPY" to wac-dept-str
				else
				move "DEPT" to wac-dept-str.
		if wad-save-dept numeric
			move wad-save-dept to wac-dept-noz
			else
			move wad-save-dept to wac-dept-no.
		if waa-print-flag = 2
			move spaces to wac-sub-string
			call "mits01vu" using
				wad-save-dept
				fzlb-rec
				fub-rec
			move fzlb-tax-district-num to wac-tax-dist-ftl8
			move fzlb-permit-number to wac-permit-ftl8
			move fzlb-ers-ref-number to wac-tax-ref-ftl8
			move fzlb-dept-name to wac-sub-string
			go to za015-pr-hl3.
		if waa-code-break = zero
			move "SUB-DEPT" to wac-sub-string
			move wad-save-sub to wac-sub-deptz
		else
			move "  COST  " to wac-sub-string
			move wad-save-sub-long to wac-sub-dept.
      *			move waa-tk-cost-code to wac-sub-dept.

	za015-pr-hl3.
		move wac-hd-line3 to paa-print-line.
		write paa-print-line after page.
		move 1 to wab-line-cnt.
		if waa-laser-throw not = zero and waa-thrown = zero
			if waa-end-totes not = zero
				 move zero to waa-end-totes
				 divide wab-page-cnt by 2
					giving wab-page-div
					remainder wab-page-rem
				 if wab-page-rem = zero
					move 1 to waa-thrown
					move wac-intention-str to
						paa-print-line
					write paa-print-line after 10
					add 10 to wab-line-cnt
					go to za010-prt-header.
		move wac-hd-line4 to paa-print-line.
		write paa-print-line after 1.
		add 1 to wab-line-cnt.
		if waf-current-alpha not = spaces
			move waf-current-alpha to paa-print-line
			write paa-print-line after 1
			add 1 to wab-line-cnt.

	za025-prt-line.
		add wab-spacing to wab-line-cnt.
		move waf-print-line to paa-print-line.
		write paa-print-line after wab-spacing.
		move 1 to wab-spacing.
		move zero to wab-margin.

	za999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	zb-format-line						section.

	zb000-start.
		if waf-data = zero
			move 1 to waa-fmt-flag
			go to zb999-exit.
		move zero to waa-fmt-flag.
		perform varying wab-maths-cnt from 1 by 1
					until wab-maths-cnt > 6
			divide waf-data-column(wab-maths-cnt) by 100
				giving waf-fmt-value(wab-maths-cnt)
		end-perform.
	
	zb999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	zc-ave-paid						section.

	zc000-start.
		if waa-print-flag = 2
			move wab-d-net-paid to wab-net-paid.
		if waa-print-flag = 3
			move wab-p-net-paid to wab-net-paid.
		perform varying wab-maths-cnt from 1 by 1
					until wab-maths-cnt > 6
			divide wae-ave-pay(wab-maths-cnt)
				by wab-net-paid
				giving wae-ave-pay(wab-maths-cnt)
		end-perform.

	zc999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	ze-fafile-dets						section.

	ze000-start.
		if waa-print-flag = 3
			move low-values to fab-key.

	ze005-start-front.
		start fa-employee-header key not < fab-key invalid key
			go to ze999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	ze015-read-fafile.
		read fa-employee-header next record
			at end
			go to ze999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	ze020-test-record.
		if fab-key = zero
			go to ze015-read-fafile.
		if waa-print-flag not = 1
			go to ze100-join.
		if waa-code-break = zero
			if fab-sub-dept not = wad-save-sub
				or fab-dept not = wad-save-dept
					go to ze999-exit.
		if waa-code-break not = zero
			if fab-dept not = wad-last-dept
      *			if fab-dept not = wad-fbb-dept
				go to ze999-exit
			end-if
			if fab-cost-code not = waa-tk-cost-code
				go to ze015-read-fafile.

	ze100-join.
		move fab-ni-class to waf-sex.
		if waf-gender = "M"
			add 1 to wab-male-cnt
			if fab-current-status = "86"
				add 1 to wab-male-left-cnt
			end-if
		else
			add 1 to wab-female-cnt
			if fab-current-status = "86"
				add 1 to wab-female-left-cnt.
		go to ze015-read-fafile.

	ze999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	zx-add-subtract						section.

	zx000-start.
		perform varying wab-maths-cnt from 1 by 1
					until wab-maths-cnt > 6
			if waa-add-sub-flag = zero
				add wag-num1-col(wab-maths-cnt) to
					wag-num2-col(wab-maths-cnt)
				else
				subtract wag-num1-col(wab-maths-cnt)
				from wag-num2-col(wab-maths-cnt)
			end-if
		end-perform.
		move zero to waa-add-sub-flag.

	zx999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	zy-ssp-recovery						section.

	zy000-start.
		if wae-ssp-rec-totals = zero
			go to zy999-exit.
		perform varying wab-maths-cnt from 1 by 1
					until wab-maths-cnt > 5
			divide wae-ssp-rec-pay(wab-maths-cnt) by 100
				giving waf-divide
			move waf-ssp-rec-perc to waf-rec-perc
			perform xb-percent-calc
			move waf-divide to
				wae-ssp-rec-pay(wab-maths-cnt)
		end-perform.
		add	wae-ssp-rec-pay(1)
			wae-ssp-rec-pay(3)
			wae-ssp-rec-pay(5)
				giving wae-ssp-rec-pay(6).

	zy999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	xb-percent-calc						section.

	xb000-start.
		multiply waf-divide by waf-rec-perc giving waf-divide.
		move waf-divide to waf-divide2.
		move waf-divide2 to waf-div-anal waf-div-anal2.
		if waf-div-dec > waf-rnd-up-value
			if waf-divide < zero
				subtract 1 from waf-divide
		    else
				add 1 to waf-divide.

	xb999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	xe-ssp-ni-line						section.

	xe000-start.
		if fac-run-type = "A" or "T"
			go to xe999-exit.
		if waa-fzq-present = zero
			go to xe999-exit.
		read fzq-file next record at end
			go to xe999-exit.
		if fzqc-eom-mkr not numeric
			move zero to fzqc-eom-mkr.
		if fzqc-eom-mkr = zero or fzqc-excess = zero
			go to xe999-exit.
		add fzqc-excess to wae-p-summ(6).
		if waa-summ-flag not = zero
			move fzqc-excess to wad-summ-amt
			move 6 to wad-summ-cnt
			perform xi-update-summ-fl.

	xe999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	xh-print-dss-summary					section.

	xh000-start.
		if fac-run-type = "A" or "T"
			go to xh999-exit.
		add 20 wab-summ-lines wab-summ-lines giving wab-margin.
		if fzqc-eom-mkr not = zero and fzqc-excess not = zero
			add 3 to wab-margin.
		move 3 to wab-spacing.
		move wppc-head-1c to waf-print-line.
		perform za-print-line.
		move wppc-head-2c to waf-print-line.
		perform za-print-line.
		move wppc-head-3c to waf-print-line.
		perform za-print-line.
		move wppc-head-4c to waf-print-line.
		perform za-print-line.
		move 2 to wab-spacing.
		if waa-summ-flag = zero
			move wae-summary-payroll-totals to fd-amounts
			move fub-tax-district-num to fd-td
			move fub-ers-ref-number to fd-ref
			go to xh600-par.
		move low-values to fd-key.
		start fd-summ-fl key not < fd-key
			invalid key
			go to xh999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xh550-loop.
		read fd-summ-fl next record
			at end
			go to xh700-start.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xh600-par.
		move spaces to waf-fmt-line.
		move fd-td to waf-summ-td.
		move fd-ref to waf-summ-ref.
		add	fd-amt(1)
			fd-amt(2) giving fd-amt(4).
		subtract fd-amt(3) from fd-amt(4).
		perform varying wab-cnt from 1 by 1 until wab-cnt > 9
			divide 100 into fd-amt(wab-cnt)
				giving waf-summ-amt(wab-cnt)
		end-perform.
		move waf-fmt-line to waf-print-line.
		perform za-print-line.
		if waa-summ-flag not = zero
			go to xh550-loop.

	xh700-start.
		move 3 to wab-spacing.
		move wppc-head-1d to waf-print-line.
		perform za-print-line.
		move wppc-head-2d to waf-print-line.
		perform za-print-line.
		move wppc-head-3d to waf-print-line.
		perform za-print-line.
		move wppc-head-4d to waf-print-line.
		perform za-print-line.
		move 2 to wab-spacing.
		if waa-summ-flag = zero
			move wae-summary-payroll-totals to fd-amounts
			move fub-tax-district-num to fd-td
			move fub-ers-ref-number to fd-ref
			go to xh800-par.
		move low-values to fd-key.
		start fd-summ-fl key not < fd-key
			invalid key
			go to xh900-notes.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xh750-loop.
		read fd-summ-fl next record
			at end
			go to xh900-notes.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xh800-par.
		move spaces to waf-fmt-line.
		move fd-td to waf-summ-td.
		move fd-ref to waf-summ-ref.
		add	fd-amt(1)
			fd-amt(2) giving fd-amt(4).
		subtract fd-amt(3) from fd-amt(4).
		add	fd-amt(6)
			fd-amt(7)
			fd-amt(8)
			fd-amt(9)
			fd-amt(10) giving fd-amt(11).
		subtract fd-amt(11) from fd-amt(5)
			giving fd-amt(12).
		add	fd-amt(4)
			fd-amt(12) giving fd-amt(13).
		perform varying wab-cnt from 10 by 1 until wab-cnt > 13
			divide 100 into fd-amt(wab-cnt)
			    giving waf-summ-amt(wab-cnt - 9)
		end-perform.
		move waf-fmt-line to waf-print-line.
		perform za-print-line.
		if waa-summ-flag not = zero
			go to xh750-loop.

	xh900-notes.
		move 3 to  wab-spacing.
		move wad-summ-notes-1 to waf-print-line.
		perform za-print-line.
		move wad-summ-notes-2 to waf-print-line.
		perform za-print-line.
		move 2 to wab-spacing.
		if fzqc-eom-mkr = zero or fzqc-excess = zero
			go to xh999-exit.
		divide 100 into fzqc-excess giving wad-ssp-notes1-val.
		move wad-ssp-notes-1 to waf-print-line.
		perform za-print-line.
		move wad-ssp-notes-2 to waf-print-line.
		perform za-print-line.

	xh999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	xi-update-summ-fl					section.

	xi000-start.
		if waa-special-split not = zero
			go to xi999-exit.
		if waa-summ-flag = zero
			go to xi999-exit.
		if waa-summ-flag = 2
			go to xi050-par.
		move wad-save-dept to fzcb-key.
		read fzc-multi-tax-depts
			invalid key
			move fub-tax-district-num to fd-td
			move fub-ers-ref-number to fd-ref
			go to xi100-read.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		move fzcb-tax-district-num to fd-td.
		move fzcb-ers-ref-number to fd-ref.
		go to xi100-read.

	xi050-par.
		call "mits01vu" using
			wad-save-dept
			fzlb-rec
			fub-rec.
		move fzlb-tax-district-num to fd-td.
		move fzlb-ers-ref-number to fd-ref.
		go to xi100-read.

	xi100-read.
		move zero to waa-new-rec-mkr.
		read fd-summ-fl
			invalid key
			move 1 to waa-new-rec-mkr
			move zero to fd-amounts.
		if wzz-io-err-code not = zero
			perform zza-io-err.
		add wad-summ-amt to fd-amt(wad-summ-cnt).
		if waa-new-rec-mkr = zero
			rewrite fd-summ-record
			else
			add 1 to wab-summ-lines
			write fd-summ-record.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xi999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	xj-print-dss-summary					section.

	xj000-start.
		if fac-run-type = "A" or "T"
			go to xj999-exit.
		add 20 wab-summ-lines wab-summ-lines giving wab-margin.
		if fzqc-eom-mkr not = zero and fzqc-excess not = zero
			add 3 to wab-margin.
		move 3 to wab-spacing.
		move wppc-head-1e to waf-print-line.
		perform za-print-line.
		move wppc-head-2e to waf-print-line.
		perform za-print-line.
		move wppc-head-3e to waf-print-line.
		perform za-print-line.
		move wppc-head-4e to waf-print-line.
		perform za-print-line.
		move 2 to wab-spacing.
		if waa-summ-flag = zero
			move wae-summary-payroll-totals to fd-amounts
			move fub-tax-district-num to fd-td
			move fub-ers-ref-number to fd-ref
			go to xj600-par.
		move low-values to fd-key.
		start fd-summ-fl key not < fd-key
			invalid key
			go to xj999-exit.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xj550-loop.
		read fd-summ-fl next record
			at end
			go to xj700-start.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xj600-par.
		move spaces to waf-fmt-line.
		move fd-td to waf-summ-td.
		move fd-ref to waf-summ-ref.
		add	fd-amt(1)
			fd-amt(2) giving fd-amt(4).
		subtract fd-amt(3) from fd-amt(4).
		perform varying wab-cnt from 1 by 1 until wab-cnt > 9
			divide 100 into fd-amt(wab-cnt)
				giving waf-summ-amt(wab-cnt)
		end-perform.
		move waf-fmt-line to waf-print-line.
		perform za-print-line.
		if waa-summ-flag not = zero
			go to xj550-loop.

	xj700-start.
		move 3 to wab-spacing.
		move wppc-head-1f to waf-print-line.
		perform za-print-line.
		move wppc-head-2f to waf-print-line.
		perform za-print-line.
		move wppc-head-3f to waf-print-line.
		perform za-print-line.
		move wppc-head-4f to waf-print-line.
		perform za-print-line.
		move 2 to wab-spacing.
		if waa-summ-flag = zero
			move wae-summary-payroll-totals to fd-amounts
			move fub-tax-district-num to fd-td
			move fub-ers-ref-number to fd-ref
			go to xj800-par.
		move low-values to fd-key.
		start fd-summ-fl key not < fd-key
			invalid key
			go to xj900-notes.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xj750-loop.
		read fd-summ-fl next record
			at end
			go to xj900-notes.
		if wzz-io-err-code not = zero
			perform zza-io-err.

	xj800-par.
		move spaces to waf-fmt-line.
		move fd-td to waf-summ-td.
		move fd-ref to waf-summ-ref.
		add	fd-amt(1)
			fd-amt(2) giving fd-amt(4).
		subtract fd-amt(3) from fd-amt(4).
		add	fd-amt(6)
			fd-amt(7)
			fd-amt(8)
			fd-amt(9)
			fd-amt(10)
			fd-amt(11)
			fd-amt(12)
			fd-amt(13)
				giving fd-amt(14).
		subtract fd-amt(14) from fd-amt(5)
			giving fd-amt(15).
		add	fd-amt(4)
			fd-amt(15) giving fd-amt(16).
		perform varying wab-cnt from 10 by 1 until wab-cnt > 16
			divide 100 into fd-amt(wab-cnt)
			    giving waf-summ-amt(wab-cnt - 9)
		end-perform.
		move waf-fmt-line to waf-print-line.
		perform za-print-line.
		if waa-summ-flag not = zero
			go to xj750-loop.

	xj900-notes.
		move 3 to  wab-spacing.
		move wad-summ-notes-1 to waf-print-line.
		perform za-print-line.
		move wad-summ-notes-2 to waf-print-line.
		perform za-print-line.
		move 2 to wab-spacing.
		if fzqc-eom-mkr = zero or fzqc-excess = zero
			go to xj999-exit.
		divide 100 into fzqc-excess giving wad-ssp-notes1-val.
		move wad-ssp-notes-1 to waf-print-line.
		perform za-print-line.
		move wad-ssp-notes-2 to waf-print-line.
		perform za-print-line.

	xj999-exit.
		exit.

      *******************************************************************
      ///////////////////////////////////////////////////////////////////
	z-general						section.

	copy "zza.rtn".
	copy "zzb.rtn".
	copy "za.proc".

      *******************************************************************

 
