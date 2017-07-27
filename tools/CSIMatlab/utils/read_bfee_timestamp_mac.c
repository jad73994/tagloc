/*
 * (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
 */

#include "mex.h"

/* The computational routine */
void read_bfee_timestamp_mac(unsigned char *inBytes, mxArray *outCell)
{
	unsigned long timestamp_low = inBytes[0] + (inBytes[1] << 8) +
		(inBytes[2] << 16) + (inBytes[3] << 24);
	unsigned short bfee_count = inBytes[4] + (inBytes[5] << 8);
	unsigned int Nrx = inBytes[8];
	unsigned int Ntx = inBytes[9];
	unsigned int rssi_a = inBytes[10];
	unsigned int rssi_b = inBytes[11];
	unsigned int rssi_c = inBytes[12];
	char noise = inBytes[13];
	unsigned int agc = inBytes[14];
	unsigned int antenna_sel = inBytes[15];
	unsigned int len = inBytes[16] + (inBytes[17] << 8);
	unsigned int fake_rate_n_flags = inBytes[18] + (inBytes[19] << 8);
	unsigned int calc_len = (30 * (Nrx * Ntx * 8 * 2 + 3) + 7) / 8;
	unsigned int i, j;
	unsigned int index = 0, remainder;
    unsigned long tv_sec = inBytes[20] + (inBytes[21] << 8) +
		(inBytes[22] << 16) + (inBytes[23] << 24);
    unsigned long tv_usec = inBytes[24] + (inBytes[25] << 8) +
		(inBytes[26] << 16) + (inBytes[27] << 24);
    unsigned char *mac = &inBytes[28];
	unsigned char *payload = &inBytes[34];
	char tmp;
    mxArray *perm;
	int size[] = {Ntx, Nrx, 30};
	mxArray *csi = mxCreateNumericArray(3, size, mxDOUBLE_CLASS, mxCOMPLEX);
	double* ptrR = (double *)mxGetPr(csi);
	double* ptrI = (double *)mxGetPi(csi);
    
        /* Create MAC address */
    int mac_size[] = {1, 6};
    double *mac_real;
    int perm_size[] = {1, 3};
    mxArray *mac_arr = mxCreateNumericArray(2, mac_size, mxDOUBLE_CLASS, mxCOMPLEX);
    
    mac_real = (double*) mxGetPr(mac_arr);
    mac_real[0] = (double)mac[0];
    mac_real[1] = (double)mac[1];
    mac_real[2] = (double)mac[2];
    mac_real[3] = (double)mac[3];
    mac_real[4] = (double)mac[4];
    mac_real[5] = (double)mac[5];


	/* Check that length matches what it should */
	if (len != calc_len)
		mexErrMsgIdAndTxt("MIMOToolbox:read_bfee_new:size","Wrong beamforming matrix size.");

	/* Compute CSI from all this crap :) */
	for (i = 0; i < 30; ++i)
	{
		index += 3;
		remainder = index % 8;
		for (j = 0; j < Nrx * Ntx; ++j)
		{
			tmp = (payload[index / 8] >> remainder) |
				(payload[index/8+1] << (8-remainder));
			/*printf("%d\n", tmp);*/
			*ptrR = (double) tmp;
			++ptrR;
			tmp = (payload[index / 8+1] >> remainder) |
				(payload[index/8+2] << (8-remainder));
			*ptrI = (double) tmp;
			++ptrI;
			index += 16;
		}
	}

	/* Compute the permutation array */
	
	perm = mxCreateNumericArray(2, perm_size, mxDOUBLE_CLASS, mxREAL);
	ptrR = (double *)mxGetPr(perm);
	ptrR[0] = ((antenna_sel) & 0x3) + 1;
	ptrR[1] = ((antenna_sel >> 2) & 0x3) + 1;
	ptrR[2] = ((antenna_sel >> 4) & 0x3) + 1;

	mxDestroyArray(mxGetField(outCell, 0, "timestamp_low"));
	mxDestroyArray(mxGetField(outCell, 0, "bfee_count"));
	mxDestroyArray(mxGetField(outCell, 0, "Nrx"));
	mxDestroyArray(mxGetField(outCell, 0, "Ntx"));
	mxDestroyArray(mxGetField(outCell, 0, "rssi_a"));
	mxDestroyArray(mxGetField(outCell, 0, "rssi_b"));
	mxDestroyArray(mxGetField(outCell, 0, "rssi_c"));
	mxDestroyArray(mxGetField(outCell, 0, "noise"));
	mxDestroyArray(mxGetField(outCell, 0, "agc"));
	mxDestroyArray(mxGetField(outCell, 0, "perm"));
	mxDestroyArray(mxGetField(outCell, 0, "rate"));
	mxDestroyArray(mxGetField(outCell, 0, "csi"));
    mxDestroyArray(mxGetField(outCell, 0, "tv_sec"));
    mxDestroyArray(mxGetField(outCell, 0, "tv_usec"));
	mxSetField(outCell, 0, "timestamp_low", mxCreateDoubleScalar((double)timestamp_low));
	mxSetField(outCell, 0, "bfee_count", mxCreateDoubleScalar((double)bfee_count));
	mxSetField(outCell, 0, "Nrx", mxCreateDoubleScalar((double)Nrx));
	mxSetField(outCell, 0, "Ntx", mxCreateDoubleScalar((double)Ntx));
	mxSetField(outCell, 0, "rssi_a", mxCreateDoubleScalar((double)rssi_a));
	mxSetField(outCell, 0, "rssi_b", mxCreateDoubleScalar((double)rssi_b));
	mxSetField(outCell, 0, "rssi_c", mxCreateDoubleScalar((double)rssi_c));
	mxSetField(outCell, 0, "noise", mxCreateDoubleScalar((double)noise));
	mxSetField(outCell, 0, "agc", mxCreateDoubleScalar((double)agc));
	mxSetField(outCell, 0, "perm", perm);
	mxSetField(outCell, 0, "rate", mxCreateDoubleScalar((double)fake_rate_n_flags));
	mxSetField(outCell, 0, "csi", csi);
    mxSetField(outCell, 0, "tv_sec", mxCreateDoubleScalar((double)tv_sec));
    mxSetField(outCell, 0, "tv_usec", mxCreateDoubleScalar((double)tv_usec));
    mxSetField(outCell, 0, "mac", mac_arr); /* Swarun */

	/* printf("Nrx: %u Ntx: %u len: %u calc_len: %u\n", Nrx, Ntx, len, calc_len); */
}

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[],
	         int nrhs, const mxArray *prhs[])
{
	unsigned char *inBytes;		/* A beamforming matrix */
	mxArray *outCell;		/* The cellular output */
    const char* fieldnames[] = {"timestamp_low",
		"bfee_count",
		"Nrx", "Ntx",
		"rssi_a", "rssi_b", "rssi_c",
		"noise",
		"agc",
		"perm",
		"rate",
		"csi",
        "tv_sec",
        "tv_usec", 
        "mac"};
	/* check for proper number of arguments */
	if(nrhs!=1) {
		mexErrMsgIdAndTxt("MIMOToolbox:read_bfee_new:nrhs","One input required.");
	}
	if(nlhs!=1) {
		mexErrMsgIdAndTxt("MIMOToolbox:read_bfee_new:nlhs","One output required.");
	}
	/* make sure the input argument is a char array */
	if (!mxIsClass(prhs[0], "uint8")) {
		mexErrMsgIdAndTxt("MIMOToolbox:read_bfee_new:notBytes","Input must be a char array");
	}

	/* create a pointer to the real data in the input matrix */
	inBytes = mxGetData(prhs[0]);

	/* create the output matrix */

	outCell = mxCreateStructMatrix(1, 1, 15, fieldnames);


	/* call the computational routine */
	read_bfee_timestamp_mac(inBytes,outCell);

	/* */
	plhs[0] = outCell;
}
