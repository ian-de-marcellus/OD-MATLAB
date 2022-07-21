function test_simulations()
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    close all;

    bound = 0.1;
    num_agents = 30;
    num_zealots = 30;
    random = randi([0 1], num_agents, num_agents);
    agent_adjacency = abs(random - random');
    num_steps_NZ = 20;
    num_steps_Z = 30;

    following = randi([0 1], num_zealots, num_agents);

    agent_opinions = rand(1, num_agents);
    zealot_opinions = rand(1, num_zealots);

    % Discrete agents (w zealots), continuous time

    continuous_timestep = 0.1;
    num_steps_Z_cont = num_steps_Z/continuous_timestep;
    modelC = HK_Zealots_Discrete_Agent_Cont_Time(bound, num_agents, num_zealots, agent_adjacency, following, agent_opinions, zealot_opinions, continuous_timestep);

    modelC.simulate_steps(num_steps_Z_cont);
    dataC = modelC.get_data();

    zealot_data_ZC = repmat(zealot_opinions, num_steps_Z_cont, 1);

    dataC = [dataC zealot_data_ZC];


    % Discrete agents (w zealots), discrete time

    model = Hegselmann_Krause_Zealots_Model(bound, num_agents, num_zealots, agent_adjacency, following, agent_opinions, zealot_opinions);

    model.simulate_steps(num_steps_Z);
    data = model.get_data();

    zealot_data_Z = repmat(zealot_opinions, num_steps_Z, 1);

    data = [data zealot_data_Z];

    % disp(data);
%     bound2 = [repelem(bound, num_agents), repelem(0, num_zealots)];
%     num_total = num_agents+num_zealots;
%     tot_adjacency = [agent_adjacency; following];
%     tot_opinions = [agent_opinions, zealot_opinions];
% 
%     model2 = Hegselmann_Krause_Model_Hetero(bound2, num_total, tot_adjacency, tot_opinions);
% 
%     model2.simulate_steps(num_steps_NZ);
%     data2 = model2.get_data();
% 
%     zealot_data_NZ = repmat(zealot_opinions, num_steps_NZ, 1);
% 
%     data2 = [data2 zealot_data_NZ];

    % disp(data2);


%     subplot(2,2,1);
%     title('With No Zealots Histogram')
%     bar(data2);
% 
%     subplot(2,2,2);
%     title('Individual Opinion As Rows Over Time No Zealots')
%     imagesc(data2',[0,1]);
%     colorbar;
% 
%     subplot(2,2,3);
%     title('With Zealots Histogram')
%     bar(data);
% 
%     subplot(2,2,4);
%     title('Individual Opinion As Rows Over Time With Zealots')
%     imagesc(data',[0,1]);
%     colorbar;
%     
%     titletext = num_agents + " Agents, " + num_zealots + " Zealots, confidence bound: " + bound;
%     sgtitle(titletext)
% 
%     model.setPath("../../Simulation Videos/");
%     model.videoName = "zealot_sim";
%     model.writeVideo(1, model.time);
% 
%     model2.setPath("../../Simulation Videos/");
%     model2.videoName = "no_zealot_sim";
%     model2.writeVideo(1, model2.time);




    subplot(2,2,1);
    title('Continuous Time Histogram')
    bar(dataC);

    subplot(2,2,2);
    title('Individual Opinion As Rows Over Continuous Time')
    imagesc(dataC',[0,1]);
    colorbar;

    subplot(2,2,3);
    title('Discrete Time Histogram')
    bar(data);

    subplot(2,2,4);
    title('Individual Opinion As Rows Over Discrete Time')
    imagesc(data',[0,1]);
    colorbar;
    
    titletext = num_agents + " Agents, " + num_zealots + " Zealots, confidence bound: " + bound;
    sgtitle(titletext)

    modelC.setPath("../../Simulation Videos/");
    modelC.videoName = "cont_z_time_sim";
    modelC.writeVideo(1, (modelC.time-1)/continuous_timestep);

    model.setPath("../../Simulation Videos/");
    model.videoName = "disc_time_z_sim";
    model.writeVideo(1, model.time);



end

function visualizeimage(simulation)
map = [255 0 2
        255 4 2
        254 7 2
        254 11 2
        253 14 1
        253 18 1
        252 21 1
        252 25 1
        251 28 1
        251 32 1
        250 35 1
        250 39 1
        249 42 1
        249 46 1
        248 49 1
        248 53 1
        247 56 1
        247 60 1
        246 63 1
        246 67 1
        245 70 1
        245 74 1
        244 77 1
        244 81 1
        243 84 1
        243 88 1
        242 91 1
        242 95 1
        241 98 1
        241 102 1
        240 105 1
        240 109 1
        239 112 1
        239 116 1
        239 119 1
        238 123 1
        238 126 1
        237 130 1
        237 133 1
        236 137 1
        236 140 1
        235 144 1
        235 147 1
        234 151 1
        234 154 1
        233 158 1
        233 161 1
        232 165 1
        232 168 1
        231 172 1
        231 175 1
        230 179 1
        230 182 1
        229 186 1
        229 189 1
        228 193 1
        228 196 1
        227 200 1
        227 203 1
        226 207 1
        226 210 1
        225 214 1
        225 217 1
        224 221 1
        223 223 2
        220 223 5
        216 223 8
        213 223 12
        209 223 15
        206 222 18
        202 222 22
        199 222 25
        195 222 28
        192 222 31
        188 221 35
        185 221 38
        181 221 41
        178 221 45
        174 221 48
        170 221 51
        167 220 55
        163 220 58
        160 220 61
        156 220 65
        153 220 68
        149 219 71
        146 219 75
        142 219 78
        139 219 81
        135 219 85
        132 219 88
        128 218 91
        125 218 95
        121 218 98
        118 218 101
        114 218 105
        111 217 108
        107 217 111
        104 217 115
        100 217 118
        97 217 121
        93 217 124
        90 216 128
        86 216 131
        83 216 134
        79 216 138
        76 216 141
        72 215 144
        69 215 148
        65 215 151
        62 215 154
        58 215 158
        54 215 161
        51 214 164
        47 214 168
        44 214 171
        40 214 174
        37 214 178
        33 213 181
        30 213 184
        26 213 188
        23 213 191
        19 213 194
        16 213 198
        12 212 201
        9 212 204
        5 212 208
        2 212 211
        1 210 213
        3 207 213
        5 203 214
        7 200 215
        9 197 216
        12 193 216
        14 190 217
        16 187 218
        18 183 218
        20 180 219
        22 177 219
        24 174 220
        26 170 221
        28 167 222
        31 164 222
        33 160 223
        35 157 224
        37 154 224
        39 150 225
        41 147 226
        43 144 226
        45 140 227
        47 137 227
        50 134 228
        52 130 229
        54 127 230
        56 124 230
        58 120 231
        60 117 232
        62 114 232
        64 110 233
        66 107 234
        69 104 234
        71 100 235
        73 97 235
        75 94 236
        77 91 237
        79 87 238
        81 84 238
        83 81 239
        85 77 240
        88 74 240
        90 71 241
        92 67 242
        94 64 242
        96 61 243
        98 57 244
        100 54 244
        102 51 245
        104 47 245
        107 44 246
        109 41 247
        111 37 248
        113 34 248
        115 31 249
        117 27 250
        119 24 250
        121 21 251
        123 17 252
        125 14 252
        128 11 253
        130 7 254
        132 4 254
        134 1 255
        136 0 252
        138 0 248
        140 0 244
        142 0 240
        143 0 236
        145 0 232
        147 0 228
        149 0 224
        151 0 220
        153 0 216
        155 0 212
        157 0 208
        159 0 204
        161 0 200
        163 0 196
        164 0 192
        166 0 188
        168 0 184
        170 0 180
        172 0 176
        174 0 172
        176 0 168
        178 0 164
        180 0 160
        182 0 156
        183 0 152
        185 0 148
        187 0 144
        189 0 140
        191 0 136
        193 0 132
        195 0 128
        197 0 124
        199 0 120
        201 0 116
        202 0 112
        204 0 108
        206 0 104
        208 0 100
        210 0 96
        212 0 92
        214 0 88
        216 0 84
        218 0 80
        220 0 76
        222 0 72
        223 0 68
        225 0 64
        227 0 60
        229 0 56
        231 0 52
        233 0 48
        235 0 44
        237 0 40
        239 0 36
        241 0 32
        242 0 28
        244 0 24
        246 0 20
        248 0 16
        250 0 12
        252 0 8
        254 0 4
        255 0 0];
    map = uint8(map);
    colormap(map)
    
    imagesc(simulation,[0,1])
    colorbar
end