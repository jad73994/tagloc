function channels  = get_channels_from_model(model,src,dst,enable_printing)
    lambda = model.lambda;
    amps = model.amps;
    if(enable_printing)
        figure; 
        display_model(model);
    end
    %% Check if there are reflections
    rays{1} = [src;dst]; %Direct path
    ray_status=[0,0];
    for i=1:length(model.reflectors)
        [p,t]=is_reflect(src,dst, model.reflectors{i});    
        if(t)
            rays{end+1} =[src;p;dst]; % Add a reflected path
            ray_status(end+1,:)=[1,i];
        end    
    end

    %% Check if a ray is blocked

    % Collect all blocking line segments into one array
    all_blocking_rays ={};
    blocking_ray_status=[];
    for j=1:length(model.reflectors)
        all_blocking_rays{end+1}=model.reflectors{j};
        blocking_ray_status(end+1,:)=[1,j];
    end
    for j=1:length(model.obstacles)
        for k=1:size(model.obstacles{j},1)
            start_point = model.obstacles{j}(k,:);
            if(k==size(model.obstacles{j},1))
                end_point = model.obstacles{j}(1,:);
            else
                end_point = model.obstacles{j}(k+1,:);
            end
            all_blocking_rays{end+1}=[start_point;end_point];
            blocking_ray_status(end+1,:)=[0,j];
        end
    end 

    is_ray_blocked = false(length(rays),1);
    for i=1:length(rays)
        % Check if these line segments are blocking the signal

        for j=1:length(all_blocking_rays)
            if(sum(abs(ray_status(i,:)-blocking_ray_status(j,:)))==0)
                if(enable_printing)
                    fprintf('Skipping because a reflector cannot block itself\n');
                end
            else
                for k=1:size(rays{i},1)-1
                    t=is_blocked(rays{i}(k:k+1,:),all_blocking_rays{j}); % Main function
                    if(t)
                        is_ray_blocked(i)=true;
                    end
                    if(is_ray_blocked(i))
                        break;
                    end
                end
                if(is_ray_blocked(i))
                    break;
                end
            end
        end


    end

    if(enable_printing)
        for i=1:length(rays)
            if(is_ray_blocked(i))
                clr = 'k';
            else
                clr = 'r';
            end
            for j=1:size(rays{i},1)-1
                plot(rays{i}(j:j+1,1),rays{i}(j:j+1,2),'-','color',clr);
            end
        end
    end

    model.rays = rays;
    model.is_ray_blocked = is_ray_blocked;

    %% Define the channels
    channels = zeros(length(lambda),1);
    for i=1:length(rays)
        if(~is_ray_blocked(i))
            cur_d = 0;
            for j=1:size(rays{i},1)-1
                cur_d = cur_d + norm(rays{i}(j+1,:)-rays{i}(j,:));
            end
            for j=1:length(lambda)
                channels(j) = channels(j) + amps(j)*1/(cur_d/lambda(j))*exp(-1j*2*pi/lambda(j)*cur_d);
            end
        end
    end    
end