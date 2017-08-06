#include "config.h"
#include "lte_constants.h"
#include "sysutils.h"

#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>                // for gettimeofday()
#include <stdbool.h>
#include <stdint.h>
#include <math.h>


// parmaters

#define PI 3.14159265358979323846



int main(int argc, char *argv[])
{

  if (argc != 4) {
    fprintf(stderr, "Usage: %s carrier_freq number_of_seconds number_of_antennas\n", argv[0]);
    exit(1);
  }

	int write_ret;
	int carrier_freq=atoi(argv[1]);
	int nant = atoi(argv[3]);
	//int len = NPAGES * getpagesize();
	int ii;
	double cfo_real,cfo_imag;
	double coarse_cfo;
	int32_t scaled_cfo;
	int32_t scaled_sfo;
	int16_t *wr_data_buf_16;
	uint32_t cfo_est_reg;
	int16_t prev_subframe=0;
	uint32_t prev_index=0;
	uint32_t rx_mem_pointer;
	uint8_t RX_DMA_OVF=0;

	double real_ant0_slot_0=0;
	double imag_ant0_slot_0=0;
	double real_ant0_slot_1=0;
	double imag_ant0_slot_1=0;
	double fine_cfo_real,fine_cfo_imag;
	double fine_cfo;
	double channel_slope;
	int32_t scaled_channel_slope;
	int slot_num;
	int num_logged_subframes=0;


	//	  cf[14]*(z^7) + cf[12]*(z^6) + cf[10]*(z^5) + cf[8]*(z^4) + cf[6]*(z^3) + cf[4]*(z^2) + cf[2]*(z^1) + cf[0]
	// K(z)=--------------------------------------------------------------------------------------------------------------
	//	  (2^17)*(z^7) - cf[13]*(z^6) - cf[11]*(z^5) - cf[9]*(z^4) - cf[7]*(z^3) - cf[5]*(z^2) - cf[3]*(z^1) - cf[1]
	
	// signed 18-bit integer (-131071 to 131071)
	int32_t controller_coeff[15]=  {0, // cf[0]
					0, // cf[1]
					0, // cf[2]
					0, // cf[3]
					0, // cf[4]
					0, // cf[5]
					0, // cf[6]
					0, // cf[7]
					0, // cf[8]
					/*
					7504, // cf[9]
					6554, // cf[10]
					-47776, // cf[11]
					-24746, // cf[12]
					73040, // cf[13]
					20719};// cf[14]
					*/
					0, // cf[9]
					6554, // cf[10]
					-7502, // cf[11]
					-24746, // cf[12]
					40270, // cf[13]
					20719};// cf[14]
                                        
                                        
	int8_t refs_r[20][30] ={{1,-1,-1,1,1,-1,1,1,1,-1,-1,-1,1,1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,1,1,-1,1,-1,-1},
				{-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,1,-1,1,1,-1,1,1,-1,1,1,-1,-1,1,1,1},
				{1,1,-1,1,1,1,1,1,-1,1,-1,1,1,1,-1,1,-1,1,1,-1,1,-1,-1,1,-1,-1,1,1,-1,-1},
				{-1,1,1,-1,-1,1,-1,-1,-1,-1,1,-1,1,-1,1,-1,-1,1,-1,1,-1,1,1,1,1,1,-1,1,1,-1},
				{1,1,-1,-1,-1,1,1,-1,-1,-1,1,1,-1,1,1,1,-1,-1,-1,1,-1,1,1,1,1,-1,1,-1,-1,1},
				{1,1,1,-1,1,1,1,1,-1,-1,1,1,-1,1,-1,-1,-1,1,1,1,1,-1,1,1,-1,1,-1,-1,1,-1},
				{-1,-1,-1,-1,1,-1,-1,-1,-1,1,1,-1,1,1,-1,-1,-1,1,1,1,1,1,1,1,1,1,1,-1,-1,1},
				{1,-1,1,1,-1,-1,1,1,-1,-1,-1,1,1,-1,1,1,-1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,1,1},
				{-1,-1,1,1,-1,1,-1,1,1,-1,-1,1,1,-1,1,1,-1,-1,-1,1,-1,1,-1,1,1,1,1,1,-1,-1},
				{1,-1,-1,1,-1,1,1,-1,-1,-1,-1,1,-1,-1,1,-1,1,1,1,1,-1,-1,-1,-1,1,-1,1,1,1,1},
				{-1,-1,1,1,1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,1,1,-1,1,1,1,-1,1,-1,-1,-1,1,-1,-1},
				{1,1,-1,-1,1,-1,1,-1,-1,-1,1,1,1,1,-1,1,1,1,-1,-1,1,-1,1,-1,1,1,1,1,1,-1},
				{-1,1,1,-1,-1,1,-1,-1,-1,1,-1,1,1,1,1,1,1,1,1,-1,-1,1,1,1,-1,1,-1,1,-1,1},
				{-1,1,-1,-1,-1,-1,-1,1,-1,-1,1,-1,-1,-1,1,1,1,1,1,-1,-1,1,1,-1,-1,1,1,-1,1,-1},
				{1,1,1,-1,1,1,1,1,-1,1,-1,-1,-1,-1,-1,1,1,1,-1,-1,1,-1,1,1,1,1,-1,-1,-1,1},
				{-1,-1,-1,1,1,1,-1,1,-1,-1,-1,-1,1,1,-1,-1,1,1,-1,1,1,1,-1,-1,-1,-1,1,-1,1,1},
				{1,-1,1,1,-1,-1,1,1,-1,1,1,-1,1,1,1,-1,1,1,1,1,-1,-1,-1,1,1,-1,-1,-1,-1,-1},
				{-1,-1,-1,1,-1,-1,-1,-1,1,1,1,-1,-1,1,1,1,-1,-1,-1,1,-1,1,-1,-1,1,1,-1,-1,1,1},
				{-1,-1,1,1,-1,1,-1,-1,1,1,-1,-1,-1,1,-1,1,1,1,1,-1,-1,-1,1,-1,-1,1,-1,1,1,-1},
				{1,-1,-1,-1,1,1,1,1,1,-1,1,1,-1,-1,1,-1,1,1,-1,1,1,1,-1,-1,1,-1,1,1,-1,-1}};

	int8_t refs_i[20][30] ={{-1,-1,1,1,1,1,1,-1,1,1,1,1,1,-1,1,1,-1,1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,1,1},
				{-1,-1,1,-1,-1,1,-1,1,-1,-1,1,-1,1,1,-1,-1,1,1,-1,1,-1,1,-1,1,1,-1,-1,-1,1,-1},
				{-1,-1,-1,1,-1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,1,-1,1,-1,-1,-1,1,-1,1,-1,-1,-1},
				{1,-1,-1,-1,1,-1,1,1,-1,1,-1,-1,1,1,1,-1,1,1,1,1,1,-1,-1,-1,-1,-1,1,-1,-1,1},
				{1,1,1,1,-1,-1,-1,-1,1,-1,1,-1,-1,-1,-1,-1,-1,-1,1,-1,1,1,-1,-1,-1,-1,-1,-1,1,1},
				{-1,1,1,1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,-1,1,1,1,1,1,1,-1,-1,1,1},
				{-1,1,-1,-1,1,-1,1,1,1,1,-1,1,-1,1,1,1,-1,-1,-1,1,-1,-1,1,-1,1,1,1,-1,-1,1},
				{1,1,-1,1,-1,1,1,1,-1,1,1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,1,-1,-1,1,1,-1,-1,-1},
				{1,1,1,-1,1,-1,-1,1,1,1,-1,-1,1,-1,1,-1,-1,1,-1,1,-1,-1,1,-1,1,-1,-1,1,1,-1},
				{1,1,1,1,-1,-1,1,-1,-1,-1,-1,1,1,1,-1,1,1,1,-1,-1,-1,-1,1,1,-1,1,-1,1,1,1},
				{-1,1,-1,-1,1,-1,1,-1,-1,1,-1,-1,-1,-1,1,1,1,-1,1,1,-1,1,1,1,1,1,-1,1,-1,1},
				{-1,1,-1,1,1,1,-1,-1,-1,1,1,1,1,1,1,1,1,1,1,-1,1,1,1,-1,1,1,1,1,-1,-1},
				{1,1,1,-1,-1,1,-1,-1,-1,-1,1,-1,-1,-1,-1,1,1,-1,-1,1,1,-1,1,-1,-1,1,1,1,1,-1},
				{1,-1,1,-1,1,1,1,-1,-1,-1,1,1,-1,-1,1,-1,1,1,1,1,1,-1,-1,1,-1,-1,-1,1,1,-1},
				{-1,-1,-1,1,-1,1,1,-1,-1,1,1,-1,1,1,-1,-1,1,-1,-1,-1,1,1,-1,1,1,-1,-1,1,-1,-1},
				{-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,1,-1,-1,-1,-1,1,1,-1,1,-1,1,-1,-1,1,-1,1,1,-1,1},
				{1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1,1,1,1,-1,1,-1,1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1},
				{1,-1,1,-1,-1,-1,1,1,1,1,-1,1,1,-1,-1,1,-1,-1,1,1,-1,-1,-1,1,1,1,1,1,1,-1},
				{1,-1,1,1,1,-1,-1,1,1,1,1,-1,1,1,1,1,1,-1,1,1,-1,1,-1,1,1,-1,-1,-1,-1,-1},
				{-1,-1,1,-1,-1,1,-1,1,-1,1,-1,1,1,-1,-1,1,-1,1,1,-1,-1,1,-1,1,-1,-1,-1,-1,-1,1}};


	uint8_t SSS_0_data[128] =      {0xAB,0xFD,0x55,0x5E,0xAA,0xFF,0xFF,0xFD,0x55,0x55,0x55,0x7E,0xAA,0xA0,0x55,0x57,
					0xFF,0xAA,0x00,0x01,0x55,0xFF,0xD5,0x55,0x40,0xAA,0xAA,0xAA,0x02,0xAA,0xAA,0xAA,
					0xAA,0xA0,0x15,0x55,0x55,0x6A,0xAA,0xAA,0xFD,0x50,0x00,0x00,0x15,0x55,0x55,0x7E,
					0xAA,0xAA,0xAA,0xFF,0xFF,0xFF,0xFE,0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x2F,0xFF,
					0x55,0x4A,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xA0,0x55,0x55,0x55,0x54,0x00,0x00,0x00,
					0x5F,0xFF,0xFF,0xFA,0xAA,0xAA,0xBF,0x54,0x00,0x00,0x0F,0xFF,0xFF,0xFA,0x80,0x00,
					0x00,0x00,0x00,0xA8,0x00,0x00,0x02,0xAF,0xFF,0xF5,0x57,0xFF,0xAA,0xA8,0x01,0x55,
					0xFF,0xFE,0x80,0x00,0x5F,0xFF,0xFF,0xFF,0x55,0x55,0x54,0x00,0x7F,0xFF,0x55,0x02};


// initialization of interface variables

	if(init_bbregs()!=0) return -1;

	init_dma();

	wr_data_buf_16 =(int16_t *) (write_buf);

	if(load_config_hw("../configs/bf_conf.txt")!=0) return -2;
///////////////////////////////////////////////

	// mkdir LOG_DIR if it exists, and create it
	{
	  mkdir(LOG_DIR, S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
	}

	for(ii=0;ii<128;ii++)
	{
		bbregs[9]=SSS_0_data[127-ii]; // loading the pattern into the correlation engine
		usleep(3);
	}
///////////////////////////////////////////////

	for(ii=0;ii<15;ii++)
	{
		bbregs[48]=controller_coeff[ii]; // loading the coefficients into the controller
		usleep(3);
	}
///////////////////////////////////////////////
        {
                int fd_subcarriers_ind = open("../configs/controller_subcarrier_bitmask.bin", O_RDONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
                if (fd_subcarriers_ind < 1) {
		        printf("could not open file : controller_subcarrier_bitmask.bin\n");
		        return -1;
	        }
                char tmp_subc_ind[2];
	        for(ii=0;ii<735;ii++)
	        {
	                read(fd_subcarriers_ind, tmp_subc_ind, 2);
		        bbregs[50]=((1<<26)+(ii<<16)+(tmp_subc_ind[1]<<8)+tmp_subc_ind[0]); // loading controller subcarrier bitmask
	        }
	        bbregs[50]=0;
	        close(fd_subcarriers_ind);
        }
///////////////////////////////////////////////

	bbregs[6]=(4<<18)+(1800<<2)+1;//3; // thresholds for cfo estimation
	//bbregs[6]=(4<<18)+(3000<<2)+1;//3; // thresholds for cfo estimation
	bbregs[10]=(3<<2)+1;//3; // threshold and antenna mask of the correlation engine
	bbregs[14]=0x003;// FFT scaling
	bbregs[16]=0;
	bbregs[49]=0;
	bbregs[30]=0;
	
	int controller_scale=27954;
	bbregs[51]=(7056<<14)+1176;
	bbregs[52]=-controller_scale;    //RX CFO
	bbregs[53]=-(controller_scale*15360*30.72)/(7*32*carrier_freq); // RX SFO scaling
	bbregs[54]=0;//(bbregs[52]*tx_carrier_freq/rx_carrier_freq);    //  TX CFO scaling
	bbregs[55]=0;// bbregs[53]; // TX SFO scaling (same as RX SFO scaling)
	
	bbregs[5]=0; // initializing cfo step
	bbregs[15]=0; // initializing sfo step
	//bbregs[24]=(5367<<14)+2807; 
	bbregs[24]=(4823<<14)+3375; 
	bbregs[25]= ((nant == 1) ? 90 : 180); 
	//bbregs[4]|=(0x1<<4); 
	bbregs[4]&=~(0x1<<4); 
	//bbregs[4]&=(~(0x1<<5)); 
	bbregs[4]&=(~(0x1<<3));
	//bbregs[4]|=(0x1<<3);
	bbregs[4]&=(~(0x1<<17));
	bbregs[4]&=(~(0x1<<19));
	bbregs[4]&=(~(0x1<<1));
	if (nant == 1) {
	  bbregs[4]|=(0x1<<5);
	} else {
	  bbregs[4]&=(~(0x1<<5));
	}


	printf("reset reg = 0x%x \n",bbregs[4]);
	printf("cfo config reg = 0x%x \n",bbregs[6]);
	printf("sync config reg = 0x%x \n",bbregs[10]);
	usleep(1000000);


	cfo_est_reg=bbregs[7];
	cfo_real=((int16_t)(cfo_est_reg&0xFFFF));
	cfo_imag=((int16_t)(cfo_est_reg>>16));
	coarse_cfo = (atan2(cfo_imag,cfo_real))-(4*PI);//+(2*PI);
	scaled_cfo = (coarse_cfo*(1024*1024*256)/PI);
	scaled_sfo = (coarse_cfo*1*(15360.0/7.0)*(30.72/carrier_freq)*(1024*1024*8)/PI);
	bbregs[5]=scaled_cfo;
	bbregs[15]=scaled_sfo;
	ii=0;
	usleep(30000);

	while((bbregs[12]<2)||((bbregs[11]&0xFF)<7))
	{
		ii++;
		coarse_cfo+=2*PI;
		scaled_cfo = (coarse_cfo*(1024*1024*256)/PI);
		scaled_sfo = (coarse_cfo*1*(15360.0/7.0)*(30.72/carrier_freq)*(1024*1024*8)/PI);
		bbregs[5]=scaled_cfo;
		bbregs[15]=scaled_sfo;
		usleep(30000);
	}
	printf("loop value = %d \n",ii);


	for (ii=0;ii<13;ii++)
	{
		printf("frame num = %d \n",bbregs[26]&0x7FF);
		printf("index = %d \n",bbregs[26]>>13);
		printf("peak value = %d \n",bbregs[11]&0xFF);
		printf("peak index = %d \n",bbregs[11]>>8);
		printf("sync peaks per frame = %d \n\n",bbregs[12]);
		usleep(10000);
	}
	usleep(20000);

	unsigned int num_bytes_per_sc = ((nant == 1) ? 4 : 8);
	unsigned int num_w32b_per_sym = 15*12*num_bytes_per_sc/4; // 15 rbs * 12 sc/rb
	unsigned int num_w32b_per_sf = 14*num_w32b_per_sym; // 14 sym/sf
	unsigned int num_w32b_per_frame = 10*num_w32b_per_sf;  // 14 symbols/sf * 180 sc/sf * ((nant == 1) ? (4 bytes/sc) : (8 bytes/sc))
	unsigned int sep_between_c_rs_16b = 6*num_bytes_per_sc/2; // 6 sc sep between rbs


	FILE *fp_2;
	fp_2=fopen("../logs/samples.bin","w");
        int fine_cfo_state=0;
        int fine_cfo_sf=0;
        unsigned int fine_cfo_off=0;

	while(((bbregs[11]&0xFF)<7)||(bbregs[12]<2)){usleep(100);};
	usleep(1000);

	printf("cfo reg = %d \n",bbregs[5]);
	printf("sfo reg = %d \n",bbregs[15]);
	bbregs[13]=((bbregs[11]>>10)+293998)%307200;
	while((RX_DMA_OVF==0) && (num_logged_subframes<(1000*atoi(argv[2]))))
	{
		rx_mem_pointer=bbregs[26];
		if((((rx_mem_pointer&0x1FFF)-prev_subframe+8192)%8192)>350)
		{
			printf("Overflow in Rx DMA!!! \n");
			RX_DMA_OVF=1;
		}
		if((rx_mem_pointer&0x1FFF)==prev_subframe)
		{
			usleep(10);
		} else
		{
		        ++num_logged_subframes;
			if(prev_index> ((1 << 20) - num_w32b_per_sf))
			{
				write_ret=fwrite((char *)(&write_buf[prev_index]),1, (1048576-prev_index)*4,fp_2);
				if(write_ret!=((1048576-prev_index)*4)) printf("error write function returned %d \n",write_ret);
				write_ret=fwrite((char *)(write_buf),1, (prev_index-((1 << 20) - num_w32b_per_sf))*4,fp_2);
				if(write_ret!=((prev_index-((1 << 20) - num_w32b_per_sf))*4)) printf("error write function returned %d \n",write_ret);
			} else 
			{
			  write_ret=fwrite((char *)(&write_buf[prev_index]),1, (num_w32b_per_sf*4),fp_2);
			  if(write_ret!=(num_w32b_per_sf*4)) printf("error write function returned %d \n",write_ret);
			}
			
			fflush(fp_2);

                        if((fine_cfo_state<3)&&(((rx_mem_pointer&0x1FFF)-fine_cfo_sf)>30))
			{
                                fine_cfo_sf=rx_mem_pointer&0x1FFF;
                                fine_cfo_off=(rx_mem_pointer>>13);
                                fine_cfo_off=4*((fine_cfo_off+524288-((num_w32b_per_sf/2)*(fine_cfo_sf%10)))%524288);
                                fine_cfo_real=0;
                                fine_cfo_imag=0;
                                unsigned int offset_separation=0;
                                float time_separation=0;
                                if (fine_cfo_state==0){ // jump one slot (half subframe) forward (count everything in 16 bit words)
                                        //offset_separation=(2097152-4*90*7);
                                        //time_separation=7.5;
				        //slot_num=19;
				  offset_separation=(num_w32b_per_sf/2)*2; // offset_separation is in 16 bits, so all the w32b counts are multiplied by 2
                                        time_separation=-7.5;
				        slot_num=1;
                                } else if(fine_cfo_state==1){ // jump half a frame backward (count everything in 16 bit words)
				  offset_separation=((1<<21)-((num_w32b_per_sf*5)*2));
                                        time_separation=75.0;
				        slot_num=10;
                                } else { // jump one frame backward
				  offset_separation=((1<<21)-(num_w32b_per_frame*2));
                                        time_separation=150.0;
				        slot_num=0;
                                }

				for (ii=0;ii<20;ii++)
				{
				  real_ant0_slot_0=wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b)%2097152]*refs_r[0][ii]+wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+1)%2097152]*refs_i[0][ii];
					imag_ant0_slot_0=wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+1)%2097152]*refs_r[0][ii]-wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b)%2097152]*refs_i[0][ii];

					real_ant0_slot_1=wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+offset_separation)%2097152]*refs_r[slot_num][ii]+wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+offset_separation+1)%2097152]*refs_i[slot_num][ii];
					imag_ant0_slot_1=wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+offset_separation+1)%2097152]*refs_r[slot_num][ii]-wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+offset_separation)%2097152]*refs_i[slot_num][ii];

	
				        fine_cfo_real+=real_ant0_slot_1*real_ant0_slot_0+imag_ant0_slot_1*imag_ant0_slot_0;
				        fine_cfo_imag+=imag_ant0_slot_1*real_ant0_slot_0-real_ant0_slot_1*imag_ant0_slot_0;	

				}

				fine_cfo=(atan2(fine_cfo_imag,fine_cfo_real)/time_separation);
				scaled_cfo = (fine_cfo*(1024*1024*256)/PI);
				scaled_sfo = (fine_cfo*(15360.0/7.0)*(30.72/carrier_freq)*(1024*1024*8)/PI);
				bbregs[5]+=scaled_cfo;
				bbregs[15]+=scaled_sfo;
                                rx_mem_pointer=bbregs[26];
                                fine_cfo_sf=rx_mem_pointer&0x1FFF;
                                ++fine_cfo_state;
				if(1){
					printf("current subframe= %d , cfo value = %f\n",fine_cfo_sf,fine_cfo);
				}
			}
			
			if((fine_cfo_state==3)&&(((rx_mem_pointer&0x1FFF)-fine_cfo_sf)>30))
			{
                                fine_cfo_sf=rx_mem_pointer&0x1FFF;
                                fine_cfo_off=(rx_mem_pointer>>13);
                                fine_cfo_off=4*((fine_cfo_off+524288-((num_w32b_per_sf/2)*(fine_cfo_sf%10)))%524288);
                                fine_cfo_real=0;
                                fine_cfo_imag=0;
				for (ii=0;ii<29;ii++)
				{
					real_ant0_slot_0=wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b)%2097152]*refs_r[0][ii]+wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+1)%2097152]*refs_i[0][ii];
					imag_ant0_slot_0=wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b+1)%2097152]*refs_r[0][ii]-wr_data_buf_16[(fine_cfo_off+ii*sep_between_c_rs_16b)%2097152]*refs_i[0][ii];
					real_ant0_slot_1=wr_data_buf_16[(fine_cfo_off+(ii+1)*sep_between_c_rs_16b)%2097152]*refs_r[0][(ii+1)]+wr_data_buf_16[(fine_cfo_off+(ii+1)*sep_between_c_rs_16b+1)%2097152]*refs_i[0][(ii+1)];
					imag_ant0_slot_1=wr_data_buf_16[(fine_cfo_off+(ii+1)*sep_between_c_rs_16b+1)%2097152]*refs_r[0][(ii+1)]-wr_data_buf_16[(fine_cfo_off+(ii+1)*sep_between_c_rs_16b)%2097152]*refs_i[0][(ii+1)];
					fine_cfo_real+=	real_ant0_slot_1*real_ant0_slot_0+imag_ant0_slot_1*imag_ant0_slot_0;
					fine_cfo_imag+= imag_ant0_slot_1*real_ant0_slot_0-real_ant0_slot_1*imag_ant0_slot_0;

				}
				channel_slope=atan2(fine_cfo_imag,fine_cfo_real)/6.0;
				scaled_channel_slope=(channel_slope*1024*1024*8)/PI;
				if(scaled_channel_slope>524287)
				{
					printf("very large positive channel slope \n");
					bbregs[30]=-524287;
				}else if(scaled_channel_slope<-524287)
				{
					printf("very large positive channel slope \n");
					bbregs[30]=524287;
				}else
				{
					bbregs[30]=-scaled_channel_slope;
				}
                                rx_mem_pointer=bbregs[26];
                                fine_cfo_sf=rx_mem_pointer&0x1FFF;
                                ++fine_cfo_state;
				if(1){
					printf("current subframe= %d , slope value = %f\n",fine_cfo_sf,channel_slope);
				}
				bbregs[49]=(3<<1)+1;
			}
			

			prev_subframe=(prev_subframe+1)%8192;
			prev_index=(prev_index+num_w32b_per_sf)%1048576;
		}
	}
			


	bbregs[4]|=(0x1<<17);
	bbregs[4]|=(0x1<<19);
	bbregs[4]|=(0x1<<1);
	printf("reset reg = 0x%x \n",bbregs[4]);
	printf("cfo reg = %d \n",bbregs[5]);
	printf("sfo reg = %d \n",bbregs[15]);
	printf("number of written subframes = %d \n",num_logged_subframes);

	fclose(fp_2);
	
	{
	        int len = NPAGES * getpagesize();
	        int fd_controller_debug = open("../logs/controller_debug.bin", O_CREAT|O_WRONLY|O_TRUNC, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
	        if (fd_controller_debug < 1) {
		        printf("could not open file : controller_debug.bin\n");
		        return -1;
	        }
	        write_ret=write(fd_controller_debug, (char *)(controller_buf), len);
	        if(write_ret!=len){
		        printf("error write function returned %d \n",write_ret);
	        }
	        close(fd_controller_debug);
	}

	
	
	
	return(0);
}

