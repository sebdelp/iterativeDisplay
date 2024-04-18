classdef iterativeDisplay < handle
    % This class is designed to perform very quick update of figure
    % during iterative algorithms
    %
    % Author: S. Delprat, UPHF, LAMIH UMR CNRS 8201

    
    properties(SetAccess=private, GetAccess=private)
        % Property to store the counter call
        counter
        % Property to store the handle returned by the function
        handles
        % Property to store the selected axe of that function
        axes
        % Property to store the selected figure of that function
        figures

        instructionStatus  %   Structure used to set which status values are used for display

        % Other internal properties
        noIter      % Allows to know how many iteration were performed
        status=-1   % -1  = not initialized, 1 = initialization, 2=iteration, 3 = final
        mode        %  1="optimized",2="normal"
    end

    properties(SetAccess=public, GetAccess=public)
    end
    methods
        function obj=iterativeDisplay()
            % Initialize the object
            obj.mode=1; % Optimization is on by default
            obj.status=-1;
            obj.noIter=0;

            % Instruction that can only be called during init. May be
            % optimized in the other iteration or not.
            list={'title','subplot','tiledlayout','xlabel','ylabel','zlabel','yyaxis','nexttile','hold','grid','figure','box','sgtitle'};
            for i=1:length(list)
                obj.instructionStatus.(list{i})=[-1 1];
                obj.counter.(list{i})=1;
                obj.handles.(list{i})={};
                obj.figures.(list{i})={};
                obj.axes.(list{i})={};
            end

            % Object that can only be executed during final
            list={'legend'};
            for i=1:length(list)
                obj.instructionStatus.(list{i})=[3];
                obj.counter.(list{i})=1;
                obj.handles.(list{i})={};
                obj.figures.(list{i})={};
                obj.axes.(list{i})={};
            end


            list={'plot','plot3','semilogx','semilogy','loglog','surf','mesh'};
            for i=1:length(list)
                obj.instructionStatus.(list{i})=[-1 1];
                obj.counter.(list{i})=1;
                obj.handles.(list{i})={};
                obj.figures.(list{i})={};
                obj.axes.(list{i})={};
            end
            
            % No optimization
            list={'xlim','ylim','zlim'};
            for i=1:length(list)
                obj.instructionStatus.(list{i})=[1 2 3];
                obj.counter.(list{i})=1;
                obj.handles.(list{i})={};
                obj.figures.(list{i})={};
                obj.axes.(list{i})={};
            end
            
            
        end
        
        function disp(obj)
            switch(obj.status)
                case {1,-1}
                    status='init';
                case 2
                    status='iter';
                case 3 
                    status='final';
            end
            if obj.mode==1
                mode='optimization on';
            else
                mode='optimization off';
            end
            fprintf('  iterative display object with status="%s" and %s.\n',status,mode);
        end

        function skip(obj,fcns)
          % Skip the functions call
          if ~iscell(fcns)
              fcns={fcns};
          end
          if obj.noIter<2
              error('skip can only be used after the 1st iteration')
          end

          for i=1:length(fcns)
              fcn=fcns{i};
              if isfield(obj.counter,fcn)
                 obj.counter.(fcn)=obj.counter.(fcn)+1; 
              else
                error('%s is not a valid function name')
              end
          end
        end

        function disableOptimization(obj,fcns)
            % This functions disable the optimization of one function
            % As a result the original Matlab code is called at every
            % iteration.
            % The disableOptimization can only be called during the
            % initialization phase
            if obj.status>1 
                % This function is only executed during the init phase
                return
            end
            
            if ~iscell(fcns) 
                fcns={fcns};
            end

            for i=1:length(fcns)
                fcn=fcns{i};
                if ~isfield(obj.instructionStatus,fcn)
                    error('"%s" is not a valid function name for the iterativeDisplay',fcn)
                end
                % Force the execution
                obj.instructionStatus.(fcn)=[1 2 3];
            end
        end

        function activateOptimizedDisplay(obj)
            obj.mode=1;
        end
        function desactivateOptimizedDisplay(obj)
            obj.mode=2;
        end
        
        function newIteration(obj)
            if obj.status==3
                error('No more iteration are allowed after the final iteration');
            end

            % Reset the counters
            fields=fieldnames(obj.counter);
            for i=1:length(fields)
                obj.counter.(fields{i})=1;
            end
            
            if obj.noIter==0
                obj.status=1; % Initialization
            else
                obj.status=2; % Update
            end
            obj.noIter=obj.noIter+1;
        end
        function finalIteration(obj)
            obj.newIteration();
            obj.status=3;
        end
       
        function val=isOptimized(obj)
            val= obj.mode==1;
        end

        function res=isFinalIteration(obj)
            res=obj.status==3;
        end

        function res=figure(obj,varargin)
            % Create a new figure (or return its handle during optimization)
            if any(obj.status==obj.instructionStatus.figure) || obj.mode==2
                obj.handles.figure{obj.counter.figure}=figure(varargin{:});
            end
            res=obj.handles.figure{obj.counter.figure};
            obj.counter.figure=obj.counter.figure+1;
        end

        function res=tiledlayout(obj,varargin)
            % Create a tiledlayout object (or return its handle during optimizaiton)
            if any(obj.status==obj.instructionStatus.tiledlayout) || obj.mode==2
                obj.handles.tiledlayout{obj.counter.tiledlayout}=tiledlayout(varargin{:});
            end
            res=obj.handles.tiledlayout{obj.counter.tiledlayout};
            obj.counter.tiledlayout=obj.counter.tiledlayout+1;
        end

        function res=subplot(obj,varargin)
            % Create a subplot object (or return its handle during optimizaiton)
            if any(obj.status==obj.instructionStatus.subplot) ||obj.mode==2
                obj.handles.subplot{obj.counter.subplot}=subplot(varargin{:});
            end
            res= obj.handles.subplot{obj.counter.subplot};
            obj.counter.subplot=obj.counter.subplot+1;
        end

        function setOnce(obj,handle,property,val)
            arguments
                obj
                handle
                property string
                val
            end
            % Set object properties
            if any(obj.status==[1 3]) || obj.mode==2
                set(handle,property,val);
            end
        end
        function setIter(obj,handle,property,val)
            % Set object properties
            set(handle,property,val);
        end
        function res=plot(obj,varargin)
            % This function plot the data. It is restricted to a single plot
            % at a time
            % Cf. Matlab plot data
            if any(obj.status==obj.instructionStatus.plot) || obj.mode==2
                % Plot & stores handles
                varargin=fixEmptyVarargin2D(varargin{:});
                handle=plot(varargin{:});
                if any(size(handle)~=[1 1])
                    error('You can only plot one line at a time');
                end
                obj.handles.plot{obj.counter.plot}=handle;
            else
                if countNumericArguments(varargin)==1
                    % Only update y
                    obj.handles.plot{obj.counter.plot}.YData=varargin{1};
                else
                    % Update x & y data
                    obj.handles.plot{obj.counter.plot}.XData=varargin{1};
                    obj.handles.plot{obj.counter.plot}.YData=varargin{2};
                end
            end
            res=obj.handles.plot{obj.counter.plot};
            % This plot has been processed, plot next
            obj.counter.plot=obj.counter.plot+1;
        end % Plot

        function res=loglog(obj,varargin)
            % This function plot the data. It is restricted to a single plot
            % at a time
            % Cf. Matlab plot data
            if any(obj.status==obj.instructionStatus.loglog) || obj.mode==2
                % Plot & stores handles
                varargin=fixEmptyVarargin2D(varargin{:});
                handle=loglog(varargin{:});
                if any(size(handle)~=[1 1])
                    error('You can only plot  one loglog line at a time')
                end
                obj.handles.loglog{obj.counter.loglog}=handle;
            else
                if countNumericArguments(varargin)==1
                    % Only update y
                    obj.handles.loglog{obj.counter.loglog}.YData=varargin{1};
                else
                     % Update x & y data
                    obj.handles.loglog{obj.counter.loglog}.XData=varargin{1};
                    obj.handles.loglog{obj.counter.loglog}.YData=varargin{2};
                
                end
            end
            res=obj.handles.loglog{obj.counter.loglog};

            % This plot has been processed, plot next
            obj.counter.loglog=obj.counter.loglog+1;
        end

        function res=plot3(obj,varargin)
            % This function plot3 the data. It is restricted to a single plot3
            % at a time
            % Cf. Matlab plot3 data
            if any(obj.status==obj.instructionStatus.plot3) || obj.mode==2
                % plot3 & stores handles
                varargin=fixEmptyVarargin2D(varargin{:});
                handle=plot3(varargin{:});
                if any(size(handle)~=[1 1])
                    error('You can only plot3 one line at a time');
                end
                obj.handles.plot3{obj.counter.plot3}=handle;
            else
                % Update x , y & z data
                obj.handles.plot3{obj.counter.plot3}.XData=varargin{1};
                obj.handles.plot3{obj.counter.plot3}.YData=varargin{2};
                obj.handles.plot3{obj.counter.plot3}.ZData=varargin{3};
            end
            res=obj.handles.plot3{obj.counter.plot3};
            % This plot3 has been processed, plot3 next
            obj.counter.plot3=obj.counter.plot3+1;
        end % plot3


        function res=nexttile(obj,varargin)
            % call nexttile
            if any(obj.status==obj.instructionStatus.plot) || obj.mode==2
                obj.handles.nexttile{obj.counter.nexttile}=nexttile(varargin{:});
            end
            res=obj.handles.nexttile{obj.counter.nexttile};
            obj.counter.nexttile=obj.counter.nexttile+1;
        end
      
        function obj=grid(obj,varargin)
            if any(obj.status==obj.instructionStatus.grid) || obj.mode==2
                grid(varargin{:});
            end
        end
        function obj=hold(obj,varargin)
            if any(obj.status==obj.instructionStatus.hold) || obj.mode==2
                hold(varargin{:});
            end
        end
        function res=xlabel(obj,varargin)
            if obj.status==1
                % Save current axis for later usage
                obj.axes.xlabel{obj.counter.xlabel}=gca;
            end

            if any(obj.status==obj.instructionStatus.xlabel) || obj.mode==2
                obj.handles.xlabel{obj.counter.xlabel}=xlabel(obj.axes.xlabel{obj.counter.xlabel},varargin{:});
            end
            res=obj.handles.xlabel{obj.counter.xlabel};
            obj.counter.xlabel=obj.counter.xlabel+1;
        end

        function res=ylabel(obj,varargin)
            if obj.status==1
                % Save current axis for later usage
                obj.axes.ylabel{obj.counter.ylabel}=gca;
            end

            if any(obj.status==obj.instructionStatus.ylabel) || obj.mode==2
                obj.handles.ylabel{obj.counter.ylabel}=ylabel(obj.axes.ylabel{obj.counter.ylabel},varargin{:});
            end
            res=obj.handles.ylabel{obj.counter.ylabel};
            obj.counter.ylabel=obj.counter.ylabel+1;
        end
        function res=zlabel(obj,varargin)
            if obj.status==1
                % Save current axis for later usage
                obj.axes.zlabel{obj.counter.zlabel}=gca;
            end

            if any(obj.status==obj.instructionStatus.zlabel) || obj.mode==2
                obj.handles.zlabel{obj.counter.zlabel}=zlabel(obj.axes.zlabel{obj.counter.zlabel},varargin{:});
            end
            res=obj.handles.zlabel{obj.counter.zlabel};
            obj.counter.zlabel=obj.counter.zlabel+1;
        end
             

        function obj=yyaxis(obj,varargin)
            if any(obj.status==obj.instructionStatus.yyaxis) || obj.mode==2
                yyaxis(varargin{:});
            end
        end
        function res=title(obj,varargin)
            if obj.status==1 
               % Save current axis for later usage
                obj.axes.title{obj.counter.title}=gca;
            end

            if any(obj.status==obj.instructionStatus.title) || obj.mode==2
                % Call the function with the current axis
                obj.handles.title{obj.counter.title}=title( obj.axes.title{obj.counter.title},varargin{:});
            else
                % Refresh title str
                obj.handles.title{obj.counter.title}.String=varargin{1};
            end
            res= obj.handles.title{obj.counter.title};
            obj.counter.title=obj.counter.title+1;
        end
        
        function res=sgtitle(obj,varargin)
            if obj.status==1 
               % Save current axis for later usage
                obj.figures.sgtitle{obj.counter.sgtitle}=gcf;
            end

            if any(obj.status==obj.instructionStatus.sgtitle) || obj.mode==2
                % Call the function with the current axis
                obj.handles.sgtitle{obj.counter.sgtitle}=sgtitle(obj.figures.sgtitle{obj.counter.sgtitle},varargin{:});
            else
                % Refresh sgtitle str
                obj.handles.sgtitle{obj.counter.sgtitle}.String=varargin{1};
            end
            res= obj.handles.sgtitle{obj.counter.sgtitle};
            obj.counter.sgtitle=obj.counter.sgtitle+1;
        end

        function res=legend(obj,varargin)
            if obj.status==1 
               % Save current axis for later usage
                obj.axes.legend{obj.counter.legend}=gca;
            end

            if any(obj.status==obj.instructionStatus.legend) || obj.mode==2
                % Refresh the legend
                res=legend(obj.axes.legend{obj.counter.legend},varargin{:});
                obj.handles.legend{obj.counter.legend}=res;
            else
                % Only send the handle
                if obj.counter.legend<=length(obj.handles.legend)
                    res=obj.handles.legend{obj.counter.legend};
                else
                    % Legend is not available yet
                    res=[];
                end
            end
            obj.counter.legend=obj.counter.legend+1;
        end % legend

        function obj=surf(obj,varargin)
            if any(obj.status==obj.instructionStatus.surf) || obj.mode==2
                varargin=fixEmptyVarargin3D(varargin{:});
                obj.handles.surf{obj.counter.surf}=surf(varargin{:});

            else
                switch countNumericArguments(varargin)
                    case 1
                        % surf(z)
                        obj.handles.surf{obj.counter.surf}.ZData=varargin{1};
                    case 2
                        % surf(Z,c)
                        obj.handles.surf{obj.counter.surf}.ZData=varargin{1};
                        obj.handles.surf{obj.counter.surf}.CData=varargin{2};
                    case 3
                        % surf(X,Y,Z)
                        % We fix C=Z to ensure correct CData  size
                        obj.handles.surf{obj.counter.surf}.XData=varargin{1};
                        obj.handles.surf{obj.counter.surf}.YData=varargin{2};
                        obj.handles.surf{obj.counter.surf}.ZData=varargin{3};
                        obj.handles.surf{obj.counter.surf}.CData=varargin{3};
                    case 4
                        obj.handles.surf{obj.counter.surf}.XData=varargin{1};
                        obj.handles.surf{obj.counter.surf}.YData=varargin{2};
                        obj.handles.surf{obj.counter.surf}.ZData=varargin{3};
                        obj.handles.surf{obj.counter.surf}.CData=varargin{4};
                    otherwise
                        error('too many input arguments');
                end
            end
            obj.counter.surf=obj.counter.surf+1;
        end %surf
        function obj=mesh(obj,varargin)
            if any(obj.status==obj.instructionStatus.mesh) || obj.mode==2
                varargin=fixEmptyVarargin3D(varargin{:});
                obj.handles.mesh{obj.counter.mesh}=mesh(varargin{:});

            else
                switch countNumericArguments(varargin)
                    case 1
                        % Mesh(z)
                        obj.handles.mesh{obj.counter.mesh}.ZData=varargin{1};
                    case 2
                        % Mesh(Z,c)
                        obj.handles.mesh{obj.counter.mesh}.ZData=varargin{1};
                        obj.handles.mesh{obj.counter.mesh}.CData=varargin{2};
                    case 3
                        % Mesh(X,Y,Z)
                        % We fix C=Z to ensure correct CData  size
                        obj.handles.mesh{obj.counter.mesh}.XData=varargin{1};
                        obj.handles.mesh{obj.counter.mesh}.YData=varargin{2};
                        obj.handles.mesh{obj.counter.mesh}.ZData=varargin{3};
                        obj.handles.mesh{obj.counter.mesh}.CData=varargin{3};
                    case 4
                        obj.handles.mesh{obj.counter.mesh}.XData=varargin{1};
                        obj.handles.mesh{obj.counter.mesh}.YData=varargin{2};
                        obj.handles.mesh{obj.counter.mesh}.ZData=varargin{3};
                        obj.handles.mesh{obj.counter.mesh}.CData=varargin{4};
                    otherwise
                        error('Too many input arguments');
                end
            end
            obj.counter.mesh=obj.counter.mesh+1;
        end %mesh

         function res=semilogx(obj,varargin)
            % This function plot the data. It is restricted to a single plot
            % at a time
            % Cf. Matlab plot data
            if any(obj.status==obj.instructionStatus.semilogx) || obj.mode==2
                % Plot & stores handles
                varargin=fixEmptyVarargin2D(varargin{:});

                handle=semilogx(varargin{:});
                if any(size(handle)~=[1 1])
                    error('You can only plot  one semilogx line at a time')
                end
                obj.handles.semilogx{obj.counter.semilogx}=handle;
            else
                if countNumericArguments(varargin)==1
                    % Only update y
                    obj.handles.semilogx{obj.counter.semilogx}.YData=varargin{1};
                else
                    % Update x & y data
                    obj.handles.semilogx{obj.counter.semilogx}.XData=varargin{1};
                    obj.handles.semilogx{obj.counter.semilogx}.YData=varargin{2};
                end
            end
            res=obj.handles.semilogx{obj.counter.semilogx};

            % This plot has been processed, plot next
            obj.counter.semilogx=obj.counter.semilogx+1;
         end
         function res=semilogy(obj,varargin)
            % This function plot the data. It is restricted to a single plot
            % at a time
            % Cf. Matlab semilogy data
            if any(obj.status==obj.instructionStatus.semilogy) || obj.mode==2
                % Plot & stores handles
                varargin=fixEmptyVarargin2D(varargin{:});
                handle=semilogy(varargin{:});
                if any(size(handle)~=[1 1])
                    error('You can only plot  one semilogy line at a time')
                end
                obj.handles.semilogy{obj.counter.semilogy}=handle;
            else
                if countNumericArguments(varargin)==1
                      % Only update y
                    obj.handles.semilogy{obj.counter.semilogy}.YData=varargin{1};
                else
                   % Update x & y data
                    obj.handles.semilogy{obj.counter.semilogy}.XData=varargin{1};
                    obj.handles.semilogy{obj.counter.semilogy}.YData=varargin{2};
                end
            end
            res=obj.handles.semilogy{obj.counter.semilogy};

            % This plot has been processed, plot next
            obj.counter.semilogy=obj.counter.semilogy+1;
         end
         
         function lim=xlim(obj,varargin)

             if obj.status==1
                 % Save current axis for later usage
                 obj.axes.xlim{obj.counter.xlim}=gca;
             end
             if nargin==1 || ischar(varargin{1}) || isstring(varargin{1})
                 % User is querying the limits
                 lim=xlim(obj.axes.xlim{obj.counter.xlim},varargin{:});
             else
                 if any(obj.status==obj.instructionStatus.xlim) || obj.mode==2
                     % User sets the limits
                     if any(obj.status==obj.instructionStatus.xlim) || obj.mode==2
                         % set xlim & stores handles
                         xlim(obj.axes.xlim{obj.counter.xlim},varargin{:});
                         lim=[];
                     end
                 end
             end
            obj.counter.xlim=obj.counter.xlim+1;
         end % Xlim
         function lim=ylim(obj,varargin)

             if obj.status==1
                 % Save current axis for later usage
                 obj.axes.ylim{obj.counter.ylim}=gca;
             end

             if nargin==1 || ischar(varargin{1}) || isstring(varargin{1})
                 % User is querying the limits
                 lim=ylim(obj.axes.ylim{obj.counter.ylim},varargin{:});
             else
                 % User sets the limits
                 if any(obj.status==obj.instructionStatus.ylim) || obj.mode==2

                     if any(obj.status==obj.instructionStatus.ylim) || obj.mode==2
                         % set ylim & stores handles
                         ylim(obj.axes.ylim{obj.counter.ylim},varargin{:});
                         lim=[];
                     end
                 end
             end
             obj.counter.ylim=obj.counter.ylim+1;
         end % ylim

         function lim=zlim(obj,varargin)

             if obj.status==1
                 % Save current axis for later usage
                 obj.axes.zlim{obj.counter.zlim}=gca;
             end

             if nargin==1 || ischar(varargin{1}) || isstring(varargin{1})
                 % User is querying the limits
                 lim=zlim(obj.axes.zlim{obj.counter.zlim},varargin{:});
             else
                 if any(obj.status==obj.instructionStatus.zlim) || obj.mode==2

                     % User sets the limits
                     if any(obj.status==obj.instructionStatus.zlim) || obj.mode==2
                         % set zlim & stores handles
                         zlim(obj.axes.zlim{obj.counter.zlim},varargin{:});
                         lim=[];
                     end
                 end
             end
             obj.counter.zlim=obj.counter.zlim+1;
         end % zlim
        
         function box(obj,varargin)
             if any(obj.status==obj.instructionStatus.box) || obj.mode==2
                 % User is querying the limits
               box(varargin{:});
             end
             obj.counter.zlim=obj.counter.zlim+1;
         end % nox
    end

end